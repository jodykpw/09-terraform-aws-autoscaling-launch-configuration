# Autoscaling with Launch Configuration
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "4.1.0"

  # Autoscaling group
  name            = "${local.name}-asg"
  use_name_prefix = false

  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn
  # Associate ALB with ASG
  target_group_arns         = module.alb.target_group_arns

  # ASG Lifecycle Hooks
  initial_lifecycle_hooks = [
    {
      name                 = "ExampleStartupLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 60
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                 = "ExampleTerminationLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 180
      lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]

  # ASG Instance Referesh
  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 50
    }
    triggers = ["tag", "desired_capacity"] # Added Desired Capacity for demostrating the Instance Refresh scenario
  }

  # ASG Launch configuration
  lc_name   = "${local.name}-lc"
  use_lc    = true # 	Determines whether to use a launch configuration in the autoscaling group or not
  create_lc = true # 	Determines whether to create launch configuration or not

  image_id          = data.aws_ami.amzlinux2.id
  instance_type     = var.private_instance_type
  key_name          = var.instance_keypair
  user_data         = file("${path.module}/script-app1.sh")
  ebs_optimized     = false # free tier, set to false
  enable_monitoring = true

  security_groups             = [module.private_sg.security_group_id]
  associate_public_ip_address = false

  # # (LC) The maximum price to use for reserving spot instances (defaults to on-demand price) (Optional argument)
  # spot_price        = "0.004"

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      delete_on_termination = true
      encrypted             = true
      volume_type           = "gp2"
      volume_size           = "10"
    },
  ]

  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      volume_size           = "8"
      volume_type           = "gp2"
    },
  ]

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "optional" # At production grade you can change to "required", for our example if is optional we can get the content in metadata.html
    http_put_response_hop_limit = 32
  }

  tags        = local.asg_tags 
}
