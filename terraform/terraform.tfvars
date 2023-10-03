app_chart = {
  name        = "lovevery-demo-robzr"
  path        = "../helm/lovevery-demo-robzr"
  values_file = "../helm/lovevery-demo-robzr/values.yaml"
  version     = "0.1.0"
}
ingress = {
  enabled = true
}
namespace = "lovevery-demo"
