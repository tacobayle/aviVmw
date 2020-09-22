# --- IAM policy ---

resource "aws_iam_role" "vmimport" {
  name = "vmimport"
  assume_role_policy = <<EOF
{
 "Version":"2012-10-17",
 "Statement":[
    {
       "Sid":"",
       "Effect":"Allow",
       "Principal":{
          "Service":"vmie.amazonaws.com"
       },
       "Action":"sts:AssumeRole",
       "Condition":{
          "StringEquals":{
             "sts:ExternalId":"vmimport"
          }
       }
    }
 ]
}
EOF

  tags = {
    tag-key = "avi"
  }
}

resource "aws_iam_role_policy" "vmimport" {
  name = "vmimport"
  role = aws_iam_role.vmimport.id

  policy = <<-EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListBucket",
            "s3:GetBucketLocation"
         ],
         "Resource": "*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:GetObject"
         ],
         "Resource": "*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource":"*"
      }
   ]
}
  EOF
}
