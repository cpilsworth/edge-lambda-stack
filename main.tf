module "stack" {
  source   = "./modules/stack"
  for_each = toset(["stack1", "stack2"])
  name     = each.key
}