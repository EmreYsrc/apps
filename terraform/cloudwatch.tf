resource "aws_cloudwatch_log_group" "eks_log_group" {
  name              = "/aws/eks/cluster"
  retention_in_days = 7
}

resource "aws_iam_role" "cloudwatch_agent_role" {

  name = "test-eks-cluster-CloudWatchAgentRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_role_policy" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  
  lifecycle {
    create_before_destroy = true
  }
}

# Attach CloudWatch Agent to EKS worker nodes
resource "aws_launch_template" "eks_launch_template" {
  name = "eks-launch-template"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_node_instance_profile.name
  }

  user_data = base64encode(data.template_file.cloudwatch_agent_config.rendered)
}

data "template_file" "cloudwatch_agent_config" {
  template = file("${path.module}/cloudwatch-agent-config.json")
}

resource "aws_iam_instance_profile" "eks_node_instance_profile" {
  name = "eks-node-instance-profile"
  role = aws_iam_role.cloudwatch_agent_role.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name                = "HighCPUUtilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EKS"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 30
  alarm_description         = "Alarm when CPU exceeds 30% utilization"
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.alerts.arn]
  ok_actions                = [aws_sns_topic.alerts.arn]
  insufficient_data_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_memory_alarm" {
  alarm_name                = "HighMemoryUtilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/EKS"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 30
  alarm_description         = "Alarm when memory exceeds 30% utilization"
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.alerts.arn]
  ok_actions                = [aws_sns_topic.alerts.arn]
  insufficient_data_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_sns_topic" "alerts" {
  name = "eks-critical-alerts"
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "emre81.1907@gmail.com"
}

