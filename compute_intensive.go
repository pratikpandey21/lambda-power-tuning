package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"time"
)

func handler(ctx context.Context, event interface{}) (interface{}, error) {
	startTime := time.Now()
	for i := 0; i < 1000000; i++ {
	}
	endTime := time.Now()
	fmt.Println("The function took", endTime.Sub(startTime).Seconds(), "seconds to execute.")
	return nil, nil
}

func main() {
	lambda.Start(handler)
}
