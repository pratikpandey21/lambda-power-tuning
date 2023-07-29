# AWS Lambda Power Tuning

Understand the need for Power Tuning - https://pratikpandey.substack.com/p/profiling-your-aws-lambdas

## How to trigger the Step Functions -

You can find different options to trigger the Step Functions. You can trigger it through the AWS Console or from the CLI.

Here's a sample input for the same -

```
{
  "lambdaARN": "arn:aws:lambda:us-east-1:<<ACC_ID>>:function:compute_intensive",
  "powerValues": [
    128,
    192,
    256,
    512,
    1024,
    2048,
    3008
  ],
  "num": 50,
  "payload": {},
  "parallelInvocation": true,
  "strategy": "balanced"
}
```

You can find more about the different settings for the Input here - https://github.com/alexcasalboni/aws-lambda-power-tuning/blob/master/README-INPUT-OUTPUT.md

## How to Deploy Changes to AWS

`make`

This command will trigger a go build and terraform plan and apply. So just checkout the code, run make and you're sorted!
