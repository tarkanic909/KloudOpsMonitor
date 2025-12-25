package main

import (
	"log"
	"net/http"

	"github.com/tarkanic909/KloudOpsMonitor/agent/internal/config"
)

func main() {
	cfg := config.Load()
	addr := ":" + cfg.Port

	log.Printf("Starting agent %s in %s mode, connecting to backend %s", cfg.AgentID, cfg.Env, cfg.APIURL)

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	})

	http.HandleFunc("/ping-backend", func(w http.ResponseWriter, r *http.Request) {
		resp, err := http.Get(cfg.APIURL + "/health")
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("backend unreachable"))
		}

		defer resp.Body.Close()
		w.WriteHeader(resp.StatusCode)
		w.Write([]byte("backend reachable"))
	})

	log.Printf("Agent running on %s", addr)
	log.Fatal(http.ListenAndServe(addr, nil))
}
