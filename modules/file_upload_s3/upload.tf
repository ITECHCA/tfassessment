# resource "aws_s3_bucket_object" "files" {
#     #count = var.create && var.resource_create ? 1 : 0
#     #for_each = fileset(format("%s/../%s", path.module, var.upload_directory), "**")
#     #for_each = fileset(path.module, format("../../%s/%s", var.upload_directory, "**"))
#     for_each = fileset(path.root, format("%s/%s", var.upload_directory, "**"))
#     bucket = var.bucket_name
#     key = replace(each.value, var.upload_directory, "")
#     source = each.value
#     acl = "private"
#     etag = filemd5(each.value)
#     force_destroy = var.force_destroy
#     #content_type = lookup(var.mime_types, split(".", each.value)[1])
#     tags = var.tags
#     server_side_encryption = var.encryption_method
# }

resource "aws_s3_bucket_object" "files" {
    count = var.create && var.resource_create ? 1 : 0
    #for_each = fileset(format("%s/../%s", path.module, var.upload_directory), "**")
    #for_each = fileset(path.module, format("../../%s/%s", var.upload_directory, "**"))
    bucket = var.bucket_name
    key = var.file_name
    source = var.file_name
    acl = "private"
    etag = filemd5(basename(var.file_name))
    force_destroy = var.force_destroy
    #content_type = lookup(var.mime_types, split(".", each.value)[1])
    tags = var.tags
    server_side_encryption = var.encryption_method
}