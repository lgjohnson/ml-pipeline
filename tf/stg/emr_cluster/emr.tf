data "aws_s3_bucket" "logs_bucket" {
    bucket = "lgjohnson-ml-pipeline-logs"
}

resource "aws_emr_cluster" "training_cluster" {
    name = "training_cluster"
    release_label = "emr-5.24.0"
    applications = ["Spark"]

    log_uri = "s3://${data.aws_s3_bucket.logs_bucket.bucket}/training_cluster/"

    termination_protection = false
    keep_job_flow_alive_when_no_steps = false

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
        #
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
    # bootstrap_action {}
    configurations_json = <<EOF
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

}


