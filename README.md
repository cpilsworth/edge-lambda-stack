# edge-lambda-stack

This project is a demonstration of linking edge and vpc lambdas where multiple stacks are deployed.  

## Problem

When there is a single stack, the VPC lambda can be invoked directly using its `FunctionName`.  However, when there are multiple stacks created, the resources must be named differently.  Somehow the edge lambda must know what vpc lambda name to call the one in the same stack as itself.  VPC lambdas can have environment variables, but that's [not possible for edge lambdas](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-requirements-limits.html#lambda-requirements-lambda-function-configuration).  So, some other way of infering the stack name is required.

## Solution

The function is able to understand its own name from the [context object](https://docs.aws.amazon.com/lambda/latest/dg/nodejs-context.html) passed into the handler.  From it's own `context.functionName` it can understand the stack name part and append that to the to the VPC lambda functionName before invoking that.

##  Demonstration

This project creates [multiple stacks](main.tf#L3) containing both [edge](lambda/edge.js) & [vpc](lambda/vpc.js) lambdas.  The edge lambda will [invoke](lambda/edge.js#L200) the vpc lambda from the same stack when executed.  The edge lambda code is able to [infer the name of the vpc lambda](lambda/edge.js#L38-L40) at runtime to ensure the correct stack is called.

## Deploy

This project can be deployed to an aws account (assuming aws credentials are already in place) using the following command:

```bash
terraform init
terraform apply
```
