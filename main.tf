resource "aws_s3_bucket" "test" {
  bucket = "${formatdate("DD-MM-YYYY-hh-mm-ss-aa", timestamp())}-tf-bucket"


}

output "bucket_name" {
  value = aws_s3_bucket.test
}
