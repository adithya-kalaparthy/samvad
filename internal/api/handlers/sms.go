package handlers

import (
	"net/http"

	"github.com/adithya-kalaparthy/samvad/internal/api/services"
	"github.com/gin-gonic/gin"
)

func SmsHandler(ctx *gin.Context) {
	request_id := ctx.GetString("request_id")

	fact, err := services.GenerateFact(request_id)
	if err != nil {
		ctx.JSON(
			http.StatusInternalServerError,
			gin.H{"status": "ERROR", "error": "Could not generate fact from Gemini"},
		)
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"status": "OK", "fact": fact})
}
