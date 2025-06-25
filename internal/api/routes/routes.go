package routes

import (
	"github.com/adithya-kalaparthy/samvad/internal/api/handlers"
	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.RouterGroup) {
	// Define your routes here

	routerGroup := router.Group("/v1")
	{
		routerGroup.GET("/health", handlers.HealthHandler)
		routerGroup.POST("/sms", handlers.SmsHandler)
		routerGroup.POST("/email", handlers.EmailHandler)
		// Add other user-related routes as needed
	}
}
