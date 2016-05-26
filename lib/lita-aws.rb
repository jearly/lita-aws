require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require 'aws_helper/ec2'

require "lita/handlers/aws_ec2"
