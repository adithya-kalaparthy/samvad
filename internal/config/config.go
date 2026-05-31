package config

import (
	"log"
	"os"
	"path"
	"path/filepath"
	"runtime"

	"github.com/joho/godotenv"
)

// LoadEnv loads environment variables from .env file if present.
// In production (k8s/EKS), env vars come from k8s Secrets via os.Getenv,
// so .env is optional.
func LoadEnv() {
	_, fileName, _, _ := runtime.Caller(0)
	currentDir := filepath.Dir(fileName)
	envFilePath := path.Join(currentDir, "../../.env")

	if _, err := os.Stat(envFilePath); err == nil {
		err := godotenv.Load(envFilePath)
		if err != nil {
			log.Printf("Warning: failed to load .env file: %v", err)
		}
	} else {
		log.Println("No .env file found — relying on system environment variables")
	}
}

