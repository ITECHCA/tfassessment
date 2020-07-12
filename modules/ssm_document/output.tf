output "content" {
  value = data.aws_ssm_document.ssm_doc.content
}

output "arn" {
  value = data.aws_ssm_document.ssm_doc.arn
}