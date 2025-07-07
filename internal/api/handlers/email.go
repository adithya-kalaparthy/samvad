package handlers

import (
	"net/http"

	"github.com/adithya-kalaparthy/samvad/internal/api/services"
	"github.com/gin-gonic/gin"
)

type EmailRequest struct {
	Recipient string `json:"recipient" binding:"required"`
}

// EmailHandler handles email-related requests.
func EmailHandler(ses *services.SesService) gin.HandlerFunc {
	return func(c *gin.Context) {
		requestId := c.GetString("request_id")

		var req EmailRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		fact, err := services.GenerateFact(requestId)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		err = ses.SendEmail(c.Request.Context(), req.Recipient, "A Fun Fact!", fact)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send email"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"status": "OK", "message": "Email sent successfully"})
	}
}
