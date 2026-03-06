module "vpc" {
  source = "./modules/vpc"
}

module "frontend" {
  source = "./modules/frontend"
}

module "backend" {
  source         = "./modules/backend"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "database" {
  source = "./modules/database"

}