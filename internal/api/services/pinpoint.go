package services

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/pinpointsmsvoicev2"
	"github.com/aws/aws-sdk-go-v2/service/pinpointsmsvoicev2/types"
)

type PinpointService struct {
	client *pinpointsmsvoicev2.Client
}

func NewPinpointService(cfg aws.Config) *PinpointService {
	client := pinpointsmsvoicev2.NewFromConfig(cfg)
	return &PinpointService{client: client}
}

func (s *PinpointService) SendSMS(ctx context.Context, recipient, message string) error {
	_, err := s.client.SendTextMessage(ctx, &pinpointsmsvoicev2.SendTextMessageInput{
		DestinationPhoneNumber: aws.String(recipient),
		OriginationIdentity:    aws.String("your-pinpoint-origination-number"), // Replace with your Pinpoint origination number
		MessageBody:            aws.String(message),
		MessageType:            types.MessageTypeTransactional,
	})
	return err
}
