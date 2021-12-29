variable "networking" {
  type = object({
   cidr_block       = string
   vpc_name         = string
   azs              = list(string)
   public_subnets   = list(string)
   private_subnets  = list(string)
   nat_gateways     = bool
  })
  default = {
   cidr_block       = "10.0.0.0/16"
   vpc_name         = "terraform-vpc"
   azs              = ["us-east-1a", "us-east-1b"]
   public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
   private_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]
   nat_gateways     = true
  }
}