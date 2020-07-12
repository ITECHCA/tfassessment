# output "object_id" {
#     value = {
#         for obj in aws_s3_bucket_object.files:
#         obj.key => obj.id
#     }
# }

# output "object_etag" {
#     value = {
#         for obj in aws_s3_bucket_object.files:
#         obj.key => obj.etag
#     }
# }

# output "object_version_id" {
#     value = {
#         for obj in aws_s3_bucket_object.files:
#         obj.key => obj.version_id
#     }
# }

# output "path_module" {
#     value = path.root
# }