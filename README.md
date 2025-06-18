# Samvad API.

Samvad is sanskrit word for conversation. It is used in the context of communication and interaction between individuals or groups. It is a fundamental aspect of human interaction and is essential for building relationships and understanding. We are using Gin framework to build our API.

The Gin framework is a web framework for Go that is known for its simplicity and performance. It is a popular choice for building web applications and APIs in Go.

## Installation

1. Install golang: https://go.dev/doc/install. We are using golang version 1.24.2

2. Install gin
```
go get github.com/gin-gonic/gin
```

## Initial setup
1. Create a new directory for your project and navigate to it in your terminal.

2. Initialize a new Go module by running the following command:
```
go mod init github.com/your_username/samvad
```

3. Create boilerplate directory structure using
```
mkdir -p cmd/server internal/{handler,service,config} pkg
touch cmd/server/main.go .gitignore README.md
```

4. Create a github repo and push your code to it.
```
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/your_username/samvad.git
git push -u origin main
```

