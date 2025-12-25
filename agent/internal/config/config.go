package config

import "os"

type Config struct {
	AgentID string
	APIURL  string
	Port    string
	Env     string
}

func Load() Config {
	return Config{
		AgentID: getEnv("AGENT_ID", "default-agent"),
		APIURL:  getEnv("API_URL", "http://localhost:8000"),
		Port:    getEnv("AGENT_PORT", "8080"),
		Env:     getEnv("AGETNT_ENV", "dev"),
	}
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}

	return fallback
}
