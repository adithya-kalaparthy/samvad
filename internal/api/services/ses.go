package services

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/sesv2"
	"github.com/aws/aws-sdk-go-v2/service/sesv2/types"
)

type SesService struct {
	client *sesv2.Client
}

func NewSesService(cfg aws.Config) *SesService {
	client := sesv2.NewFromConfig(cfg)
	return &SesService{client: client}
}

func (s *SesService) SendEmail(ctx context.Context, recipient, subject, body string) error {
	_, err := s.client.SendEmail(ctx, &sesv2.SendEmailInput{
		FromEmailAddress: aws.String("your-verified-email@example.com"), // Replace with your verified SES email
		Destination: &types.Destination{
			ToAddresses: []string{recipient},
		},
		Content: &types.EmailContent{
			Simple: &types.Message{
				Subject: &types.Content{
					Data: aws.String(subject),
				},
				Body: &types.Body{
					Text: &types.Content{
						Data: aws.String(body),
					},
				},
			},
		},
	})
	return err
}
