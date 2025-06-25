package main

import (
	"log"

	"github.com/adithya-kalaparthy/samvad/internal/api/middlewares"
	"github.com/adithya-kalaparthy/samvad/internal/api/routes"
	"github.com/adithya-kalaparthy/samvad/internal/config"
	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()
	err := config.LoadEnv()
	if err != nil {
		log.Fatal(err)
	}
	// Setup routes.
	routerGroup := router.Group("/api")
	// Define your middlewares in a slice
	// The order here matters, as middlewares are executed in the order they are added.
	var apiMiddlewares = []gin.HandlerFunc{
		middlewares.AuthorizeMiddleware(),
		middlewares.RequestIdMiddleware(),
	}

	routerGroup.Use(apiMiddlewares...)
	routes.SetupRoutes(routerGroup)
	// Start the server.
	routerErr := router.Run(":8080")
	if routerErr != nil {
		log.Fatalf("Server failed to start: %v", routerErr) // Log the error and exit
	}
}
