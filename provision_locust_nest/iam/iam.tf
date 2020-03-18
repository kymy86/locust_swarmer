resource "aws_iam_role" "locust" {
  name               = "locust_role"
  assume_role_policy = file("${path.module}/policies/role.json")
}

data "template_file" "iam_policy" {
  template = file("${path.module}/policies/policy.json")
  vars = {
    bucket_arn = var.bucket_arn
  }
}


resource "aws_iam_role_policy" "locust" {
  name   = "locust_policy"
  policy = data.template_file.iam_policy.rendered
  role   = aws_iam_role.locust.id
}

resource "aws_iam_instance_profile" "locust" {
  name = "locust_profile"
  path = "/"
  role = aws_iam_role.locust.name
}
