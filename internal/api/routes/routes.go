package routes

import (
	"context"
	"log"

	"github.com/adithya-kalaparthy/samvad/internal/api/handlers"
	"github.com/adithya-kalaparthy/samvad/internal/api/services"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.RouterGroup) {
	// Define your routes here
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("your-aws-region"))
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	sesService := services.NewSesService(cfg)
	pinpointService := services.NewPinpointService(cfg)

	routerGroup := router.Group("/v1")
	{
		routerGroup.GET("/health", handlers.HealthHandler)
		routerGroup.POST("/sms", handlers.SmsHandler(pinpointService))
		routerGroup.POST("/email", handlers.EmailHandler(sesService))
		// Add other user-related routes as needed
	}
}
