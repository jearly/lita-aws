require 'aws-sdk'
# Alertlogic Helper
module AwsHelper
  # Agents Helper
  module Ec2
    def ec2_client(region)
      ec2 = Aws::EC2::Client.new(
        :access_key_id => config.access_key_id,
        :secret_access_key => config.secret_access_key,
        :region => region
      )
    end
  end
end
