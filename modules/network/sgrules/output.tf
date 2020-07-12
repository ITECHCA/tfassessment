output "sg_rule_id" {
    value = aws_security_group_rule.cidrrules.*.id
}

output "sg_rule_type" {
    value = aws_security_group_rule.cidrrules.*.type
}

output "sgid_rule_id" {
    value = aws_security_group_rule.sgrules.*.id
}

output "sgid_rule_type" {
    value = aws_security_group_rule.sgrules.*.type
}