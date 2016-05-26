module Lita
  module Handlers
    class AwsEc2 < Handler
      # config values
      config :account_number
      config :access_key_id
      config :secret_access_key

      namespace 'Aws'

      include ::AwsHelper::Ec2
      
      # Route definitions
      # instance list route
      route(
        /a(?:ws)? ec2 instance list( (.+))?/i,
        :list_instances,
        help: {
          t('help.ec2.instance.list.syntax') => t('help.aws.ec2.instance.list.desc')
        }
      )

      # instance show route
      route(
        /a(?:ws)? ec2 instance show? (.+)? (.+)?/i,
        :instance_details,
        help: {
          t('help.ec2.instance.show.syntax') => t('help.aws.ec2.instance.show.desc')
        }
      )

      # image list route
      route(
        /a(?:ws)? ec2 ami list? (.+)?/i,
        :list_images,
        help: {
          t('help.ec2.ami.list.syntax') => t('help.aws.ec2.ami.list.desc')
        }
      )

      # launch image(s) route
      route(
        /a(?:ws)? ec2 ami launch? (.+)? (.+)? (.+)? (.+)?/i,
        :launch_image,
        help: {
          t('help.ec2.ami.launch.syntax') => t('help.aws.ec2.ami.launch.desc')
        }
      )

      # copy image route
      route(
        /a(?:ws)? ec2 ami copy? (.+)? (.+)? (.+)? (.+)?/i,
        :copy_image,
        help: {
          t('help.ec2.ami.copy.syntax') => t('help.aws.ec2.ami.copy.desc')
        }
      )

      # EC2 Instance List
      def list_instances(response)
        region = response.match_data[1].strip
        instances = []
        # List EC2 instances
        client = ec2_client(region)
        list = client.describe_instances.to_a
        list[0][:reservations].each do |res| 
          res[:instances].each do |instance|
            instances << { 
              id: instance[:instance_id],
              name: instance[:key_name],
              status: instance[:state][:name],
              type: instance[:instance_type]
            }
          end
        end
        response.reply(JSON.pretty_generate(instances))
      end

      def instance_details(response)
        instance = response.match_data[1].strip
        region = response.match_data[2].strip
        client = ec2_client(region)
        resp = client.describe_instances({ instance_ids: [instance] }).data
        response.reply(JSON.pretty_generate(resp.to_h))
      end

      def list_images(response)
        region = response.match_data[1].strip
        client = ec2_client(region)
        amis = client.describe_images({owners: ['self']}).data
        response.reply(JSON.pretty_generate(amis.to_h))
      end

      def launch_image(response)
        region = response.match_data[1].strip
        ami = response.match_data[2].strip
        count = response.match_data[3].strip
        type = response.match_data[4].strip
        client = ec2_client(region)
        options = { 
          image_id: ami, # required
          min_count: count, # required
          max_count: count, # required
          instance_type: type
        }
        launch = client.run_instances(options).to_h
        response.reply(JSON.pretty_generate(launch))
      end

      def copy_image(response)
        ami = response.match_data[1].strip
        name = response.match_data[2].strip
        src_region = response.match_data[3].strip
        dest_region = response.match_data[4].strip
        client = ec2_client(dest_region)
        options = {
          source_region: src_region, # required
          source_image_id: ami, # required
          name: name, # required
        }
        copy_ami = client.copy_image(options).to_h
        response.reply(JSON.pretty_generate(copy_ami))
      end

      Lita.register_handler(self)
    end
  end
end
