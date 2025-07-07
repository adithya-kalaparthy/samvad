package handlers

import (
	"net/http"

	"github.com/adithya-kalaparthy/samvad/internal/api/services"
	"github.com/gin-gonic/gin"
)

type SmsRequest struct {
	Recipient string `json:"recipient" binding:"required"`
}

func SmsHandler(pinpoint *services.PinpointService) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		request_id := ctx.GetString("request_id")

		var req SmsRequest
		if err := ctx.ShouldBindJSON(&req); err != nil {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		fact, err := services.GenerateFact(request_id)
		if err != nil {
			ctx.JSON(
				http.StatusInternalServerError,
				gin.H{"status": "ERROR", "error": "Could not generate fact from Gemini"},
			)
			return
		}

		err = pinpoint.SendSMS(ctx.Request.Context(), req.Recipient, fact)
		if err != nil {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send SMS"})
			return
		}

		ctx.JSON(http.StatusOK, gin.H{"status": "OK", "message": "SMS sent successfully"})
	}
}
