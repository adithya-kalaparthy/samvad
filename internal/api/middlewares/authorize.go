package middlewares

import (
	"crypto/sha256"
	"encoding/hex"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

// getEncodedApiKey returns the encoded API key.
func getEncodedApiKey() string {
	key := os.Getenv("VALID_API_KEY")

	hashBytes := sha256.Sum256([]byte(key))

	return string(hex.EncodeToString(hashBytes[:]))
}

// Authorize middleware checks if the request contains a valid API key.
func AuthorizeMiddleware() gin.HandlerFunc {
	validApiKey := getEncodedApiKey()

	if validApiKey == "" {
		return func(ctx *gin.Context) {
			msg := "Internal Server Error: VALID_API_KEY environment variable is not set"
			ctx.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": msg})
			log.Printf("CRITICAL ERROR MESSAGE: %s", msg)
		}
	}

	return func(c *gin.Context) {
		// Implement authorization logic here
		requestApiKey := c.GetHeader("X-API-KEY")

		if requestApiKey == "" {
			msg := "Unauthorized: API key is missing"
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": msg})
			log.Printf("Unauthorized usage: %s", msg)
			return
		}

		if requestApiKey != validApiKey {
			msg := "Unauthorized: Invalid API key"
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": msg})
			log.Printf("Unauthorized usage: %s", msg)
			return
		}

		log.Print("Authorization successful")
		c.Next()
	}
}
