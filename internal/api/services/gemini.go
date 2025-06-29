package services

import (
	"context"
	"log"
	"os"

	"google.golang.org/genai"
)

func GenerateFact(request_id string) (string, error) {
	ctx := context.Background()
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		APIKey:  os.Getenv("GEMINI_API_KEY"),
		Backend: genai.BackendGeminiAPI,
	})
	if err != nil {
		log.Printf("%s - Failed to create client: %v", request_id, err)
		return "", err
	}

	result, err := client.Models.GenerateContent(
		ctx,
		os.Getenv("GEMINI_AI_MODEL"),
		genai.Text("Generate a randome fact about roman empire. Just give a fact. No other information"),
		nil,
	)
	if err != nil {
		log.Printf("%s - Failed to generate content: %v", request_id, err)
		return "", err
	}
	return result.Text(), nil
}
