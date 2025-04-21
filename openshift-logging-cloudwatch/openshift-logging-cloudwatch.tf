resource "aws_iam_policy" "openshift-logging-cloudwatch-policy" {
  name        = "the-cluster-openshift-logging-cloudwatch-policy"
  path        = "/"
  description = "openshift-logging cloudwatch policy"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy"
        ],
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "openshift-logging-cloudwatch-role" {
  name = "the-cluster-openshift-logging-cloudwatch-role"

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

resource "aws_iam_role_policy_attachment" "openshift_logging_cloudwatch_attach_role" {
  role       = aws_iam_role.openshift-logging-cloudwatch-role.name
  policy_arn = aws_iam_policy.openshift-logging-cloudwatch-policy.arn
}
