package handlers

import (
	"net/http"

	"github.com/adithya-kalaparthy/samvad/internal/api/services"
	"github.com/gin-gonic/gin"
)

// EmailHandler handles email-related requests.
func EmailHandler(c *gin.Context) {
	requestId := c.GetString("request_id")

	fact, err := services.GenerateFact(requestId)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"fact": fact})
}
