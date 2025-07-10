FROM golang:1.25rc2-alpine3.22

WORKDIR /app

COPY .env .

COPY . .

RUN go mod download

CMD ["go", "run", "cmd/server/main.go"]
