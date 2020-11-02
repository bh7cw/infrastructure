module "services" {
  source = "../../modules/services"

  dns_a_record_name = "api.prod.bh7cw.me."
}