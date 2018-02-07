#!/usr/bin/env ruby
#


def find_url(needle, region)
  maps = {
    subnet: "https://eu-west-1.console.aws.amazon.com/vpc/home?region=#{region}#subnets:filter=#{needle}",
    acl: "https://eu-west-1.console.aws.amazon.com/vpc/home?region=#{region}#acls:filter=#{needle}",
    rtb: "https://eu-west-1.console.aws.amazon.com/vpc/home?region=#{region}#routetables:filter=#{needle}",
    vpc: "https://console.aws.amazon.com/vpc/home?region=#{region}#vpcs:filter=#{needle}",
    sg: "https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=#{region}#SecurityGroups:search=#{needle}",
    i: "https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=#{region}#Instances:instanceId=#{needle}"
  }

  maps.each { |k, v|
    return v if /^#{k}-\h+/ =~ needle
  }

  abort("Error, i just dont know what to do with #{needle}")
end

if ARGV.length <= 0
  puts 'Please provide something to search'
  exit(0)
end

needle = ARGV[0].strip

if needle.match(/^arn/)
  # arn:aws:elasticloadbalancing:eu-west-1:905282256883:listener/app/mikek8s-6e35a19963e3126/28d49f56397cd067/89728d1c3c92630a
  region = needle.split(':')[3]
  search = needle.split('/')[2]
  url = "https://#{region}.console.aws.amazon.com/ec2/home?region=#{region}#LoadBalancers:search=#{search}"
else
  begin
    region = /region=(\w*-\w*-\d*)/.match(ARGV[1])[1]
  rescue
    region = 'eu-west-1'
  end
  url = find_url(needle, region)
end
puts url
# `open #{url}`
