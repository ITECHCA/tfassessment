# resource "aws_ssm_document" "ssm_doc" {
#   name          = var.name
#   document_type = "Command"

#   content = <<DOC
#   {
#     "schemaVersion": "1.2",
#     "description": "Check ip configuration of a Linux instance.",
#     "parameters": {

#     },
#     "runtimeConfig": {
#       "aws:runShellScript": {
#         "properties": [
#           {
#             "id": "0.aws:runShellScript",
#             "runCommand": ["ifconfig"]
#           }
#         ]
#       }
#     }
#   }
# DOC
# }

data "aws_ssm_document" "ssm_doc" {
  name            = var.name
  document_format = "YAML"
}

