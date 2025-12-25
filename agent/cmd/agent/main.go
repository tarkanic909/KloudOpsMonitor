package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/tarkanic909/KloudOpsMonitor/agent/internal/config"
	"github.com/tarkanic909/KloudOpsMonitor/agent/internal/logging"
)

func createServer(cfg config.Config) *http.Server {

	mux := http.NewServeMux()
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	})

	server := &http.Server{
		Addr:    ":" + cfg.Port,
		Handler: mux,
	}

	return server
}

func runServer(ctx context.Context, server *http.Server, shutdownTimeout time.Duration, logger *slog.Logger) error {
	serverErr := make(chan error, 1)

	// Run HTTP server in separate goroutine
	go func() {
		err := server.ListenAndServe()
		if err != nil && errors.Is(err, http.ErrServerClosed) {
			serverErr <- err
		}
		close(serverErr)
	}()

	stopSig := make(chan os.Signal, 1)

	// Use os.Interrupt is platform idependent, SIGTERM for kubernetes or docker
	signal.Notify(stopSig, os.Interrupt, syscall.SIGTERM)

	// Check channels for errors and signals
	select {
	case err := <-serverErr:
		return err
	case <-stopSig:
		logger.Info("Shutdown signal received")
	case <-ctx.Done():
		logger.Info("Context cancelled")
	}

	// Gracefull shutdown with timeout
	shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()

	// Stop receiving new requests and wait to finish existing
	err := server.Shutdown(shutdownCtx)
	if err != nil {
		closeErr := server.Close()
		if closeErr != nil {
			return errors.Join(err, closeErr)
		}
		return err
	}

	logger.Info("Server shutdown gracefully")
	return nil
}

func main() {
	// Read configuration
	cfg := config.Load()
	// Initialize structured logger
	logger := logging.New(cfg.Env)

	// Create HTTP router(ServeMux)
	server := createServer(cfg)

	logger.Info("agent started",
		"agent_id", cfg.AgentID,
		"env", cfg.Env,
		"port", cfg.Port,
	)

	err := runServer(context.Background(), server, 10*time.Second, logger)
	if err != nil {
		logger.Error("Agent error", "error", err)
	}

}
