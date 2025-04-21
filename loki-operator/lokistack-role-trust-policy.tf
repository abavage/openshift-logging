resource "aws_s3_bucket" "loki-netobserv" {
  bucket = "the-cluster-loki-netobserv"

  tags = {
    Name        = "lokistack"
    Environment = "loki-netobserv"
  }
}

resource "aws_s3_bucket" "loki-logging" {
  bucket = "the-cluster-loki-logging"

  tags = {
    Name        = "lokistack"
    Environment = "loki-logging"
  }
}


resource "aws_iam_policy" "the-cluster-lokistack-policy" {
  name        = "the-cluster-lokistack-policy"
  path        = "/"
  description = "lokistack role for all buckets"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect: "Allow"
        Action: [
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject"
        ],
        Resource: [
            "arn:aws:s3:::the-cluster-loki-netobserv",
            "arn:aws:s3:::the-cluster-loki-netobserv/*",
            "arn:aws:s3:::the-cluster-loki-logging",
            "arn:aws:s3:::the-cluster-loki-logging/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "the-cluster-lokistack-role" {
  name = "the-cluster-lokistack-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Federated : "arn:aws:iam::319668183582:oidc-provider/oidc.op1.openshiftapps.com/2i88dhgsjo3o93877cmaiquhoa1in7ij"
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "oidc.op1.openshiftapps.com/2i88dhgsjo3o93877cmaiquhoa1in7ij:sub" : "system:serviceaccount:openshift-logging:logging"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lokistack_attach_role" {
  role       = aws_iam_role.the-cluster-lokistack-role.name
  policy_arn = aws_iam_policy.the-cluster-lokistack-policy.arn
}
