resource "aws_iam_role" "locust" {
  name               = "locust_role"
  assume_role_policy = file("${path.module}/policies/role.json")
}

resource "aws_iam_role_policy" "locust" {
  name = "locust_policy"
  policy = templatefile(
    "${path.module}/policies/policy.json",
    {
      bucket_arn = var.bucket_arn
    }
  )
  role = aws_iam_role.locust.id
}

resource "aws_iam_instance_profile" "locust" {
  name = "locust_profile"
  path = "/"
  role = aws_iam_role.locust.name
}
