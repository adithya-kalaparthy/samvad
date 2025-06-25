package config

import (
	"fmt"
	"path"
	"path/filepath"
	"runtime"

	"github.com/joho/godotenv"
)

// LoadEnv loads environment variables from .env file.
func LoadEnv() error {
	_, fileName, _, _ := runtime.Caller(0)
	currentDir := filepath.Dir(fileName)
	envFilePath := path.Join(currentDir, "../../.env")

	// Load environment variables from .env file.
	err := godotenv.Load(envFilePath)
	if err != nil {
		fmt.Printf("Error loading .env file: %v\n", err)
		return err
	}
	return nil
}
