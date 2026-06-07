package services

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
)

type QuoteResponse struct {
	ID     int    `json:"id"`
	Quote  string `json:"quote"`
	Author string `json:"author"`
}

func FetchQuote(request_id string) (string, error) {
	resp, err := http.Get("https://dummyjson.com/quotes/random?delay=2000")
	if err != nil {
		log.Printf("%s - Failed to fetch quote: %v", request_id, err)
		return "", err
	}
	defer func() {
		if err := resp.Body.Close(); err != nil {
			log.Printf("%s - Failed to close response body: %v", request_id, err)
		}
	}()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Printf("%s - Failed to read response body: %v", request_id, err)
		return "", err
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	var quoteResp QuoteResponse
	if err := json.Unmarshal(body, &quoteResp); err != nil {
		log.Printf("%s - Failed to parse quote JSON: %v", request_id, err)
		return "", err
	}

	return quoteResp.Quote, nil
}
