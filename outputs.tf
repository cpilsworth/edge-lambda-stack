output "edge_lambda" {
  value = {
    for stack in module.stack :
    stack.name => stack.edge_lambda
  }
}

output "vpc_lambda" {
  value = {
    for stack in module.stack :
    stack.name => stack.vpc_lambda
  }
}
