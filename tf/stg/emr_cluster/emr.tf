data "aws_s3_bucket" "logs_bucket" {
    bucket = "lgjohnson-ml-pipeline-logs"
}


# EMR CLUSTER

resource "aws_emr_cluster" "training_cluster" {
    name = "training_cluster"
    release_label = "emr-5.24.0"
    applications = ["Spark"]

    log_uri = "s3://${data.aws_s3_bucket.logs_bucket.bucket}/training_cluster/"

    termination_protection = false
    # do not kill cluster when there are no steps.
    keep_job_flow_alive_when_no_steps = true

    ec2_attributes {
        subnet_id = "${}"
        emr_managed_master_security_group = "${}"
        emr_managed_slave_security_group = "${}"
        instance_profile = "${}"
    }

    master_instance_group {
        instance_type = "m4.large"
    }

    core_instance_group {
        instance_type = "c4.large"
        instance_count = 2

        #specifying bid_price turns the EMR cluster into a spot cluster
        # bid_price = "0.30"

        #set emr cluster to scale out by 1 instance if available memory drops below 15%
        #never scale up past 5 nor scale down past 2
        #evaluated every 5 minutes
        autoscaling_policy = <<EOF
{
    "Constraints": {
        "MinCapacity": 2,
        "MaxCapacity": 5
    },
    "Rules": [
        {
            "Name": "ScaleOutMemoryPercentage",
            "Description": "Scale out if YARNMemoryAvailablePercentage is less than 15",
            "Action": {
                "SimpleScalingPolicyConfiguration": {
                    "AdjustmentType": "CHANGE_IN_CAPACITY",
                    "ScalingAdjustment": 1,
                    "CoolDown": 300
                }
            },
            "Trigger": {
                "CloudWatchAlarmDefinition": {
                    "ComparisonOperator": "LESS_THAN",
                    "EvaluationPeriods": 1,
                    "MetricName": "YARNMemoryAvailablePercentage",
                    "Namespace": "AWS/ElasticMapReduce",
                    "Period": 300,
                    "Statistic": "AVERAGE",
                    "Threshold": 15.0,
                    "Unit": "PERCENT"
                }
            }
        }
    ]
}
EOF
    }
    ebs_root_volume_size = 100

    # actions to run before Hadoop starts up
    bootstrap_action {
        path = "s3://elasticmapreduce/bootstrap-actions/run-if"
        name = "runif"
        args = ["instance.isMaster=true", "echo running on master node"]
    }

    #EMR configuration
    configurations_json = <<EOF
    [
        {
            "Classification": "hadoop-env",
            "Configurations": [
                {
                    "Classification": "export",
                    "Properties": {
                        "JAVA_HOME": "/usr/lib/jvm/java-1.8.0"
                    }
                }
            ],
            "Properties": {}
        },
        {
            "Classification": "spark-env",
            "Configurations": [
                {
                    "Classification": "export",
                    "Properties": {
                        "JAVA_HOME": "/usr/lib/jvm/java-1.8.0"
                    }
                }
            ],
            "Properties": {}
        }
    ]
EOF
    service_role = "${}"

    step {
        action_on_failure = "TERMINATE_CLUSTER"
        name              = "Setup Hadoop Debugging"

        hadoop_jar_step {
            jar  = "command-runner.jar"
            args = ["state-pusher-script"]
        }
    }

    # ignore outside changes to running cluster steps e.g. the training step
    lifecycle {
        ignore_changes = ["step"]
    }

    service_role = "${aws_iam_role.iam_training_emr_service_role.arn}"

}



# IAM ROLES

#iam role for EMR service
resource "aws_iam_role" "iam_training_emr_service_role" {
    name = "iam_training_emr_service_role"

    assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "elasticmapreduce.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "iam_training_emr_service_policy" {
    name = "iam_training_emr_service_policy"
    role = "${aws_iam_role.iam_training_emr_service_role}"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CancelSpotInstanceRequests",
            "ec2:CreateNetworkInterface",
            "ec2:CreateSecurityGroup",
            "ec2:CreateTags",
            "ec2:DeleteNetworkInterface",
            "ec2:DeleteSecurityGroup",
            "ec2:DeleteTags",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInstances",
            "ec2:DescribeKeyPairs",
            "ec2:DescribeNetworkAcls",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribePrefixLists",
            "ec2:DescribeRouteTables",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSpotInstanceRequests",
            "ec2:DescribeSpotPriceHistory",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeVpcEndpoints",
            "ec2:DescribeVpcEndpointServices",
            "ec2:DescribeVpcs",
            "ec2:DetachNetworkInterface",
            "ec2:ModifyImageAttribute",
            "ec2:ModifyInstanceAttribute",
            "ec2:RequestSpotInstances",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:RunInstances",
            "ec2:TerminateInstances",
            "ec2:DeleteVolume",
            "ec2:DescribeVolumeStatus",
            "ec2:DescribeVolumes",
            "ec2:DetachVolume",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "iam:ListInstanceProfiles",
            "iam:ListRolePolicies",
            "iam:PassRole",
            "s3:CreateBucket",
            "s3:Get*",
            "s3:List*",
            "sdb:BatchPutAttributes",
            "sdb:Select",
            "sqs:CreateQueue",
            "sqs:Delete*",
            "sqs:GetQueue*",
            "sqs:PurgeQueue",
            "sqs:ReceiveMessage"
        ]
    }]
}
EOF
}

#iam role for EMR instance profile
resource "aws_iam_role" "iam_training_emr_profile_role" {
    name = "iam_training_emr_profile_role"

    assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "training_emr_profile" {
    name = "emr_profile"
    roles = ["${aws_iam_role.iam_training_emr_profile_role.name}"]
}

resource "aws_iam_role_policy" "iam_training_emr_profile_policy" {
    name = "iam_training_emr_profile_policy"
    role = "${aws_iam_role.iam_training_emr_profile_role.id}"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "cloudwatch:*",
            "dynamodb:*",
            "ec2:Describe*",
            "elasticmapreduce:Describe*",
            "elasticmapreduce:ListBootstrapActions",
            "elasticmapreduce:ListClusters",
            "elasticmapreduce:ListInstanceGroups",
            "elasticmapreduce:ListInstances",
            "elasticmapreduce:ListSteps",
            "kinesis:CreateStream",
            "kinesis:DeleteStream",
            "kinesis:DescribeStream",
            "kinesis:GetRecords",
            "kinesis:GetShardIterator",
            "kinesis:MergeShards",
            "kinesis:PutRecord",
            "kinesis:SplitShard",
            "rds:Describe*",
            "s3:*",
            "sdb:*",
            "sns:*",
            "sqs:*"
        ]
    }]
}
EOF
}