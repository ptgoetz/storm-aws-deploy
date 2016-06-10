require 'uri'

STORM_DIST_URL = "http://mirror.symnds.com/software/Apache/storm/apache-storm-1.0.1/apache-storm-1.0.1.zip"
STORM_SUPERVISOR_COUNT = 3
# end Configuration

STORM_ARCHIVE = File.basename(URI.parse(STORM_DIST_URL).path)
STORM_VERSION = File.basename(STORM_ARCHIVE, '.*')


Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  aws_route53_zone = ENV['AWS_ROUTE53_ZONE']
  aws_route53_domain = ENV['AWS_ROUTE_53_DOMAIN']

  config.vm.provider :aws do |aws, override|
    #aws.access_key_id = ENV['AWS_KEY']
    aws.access_key_id =  ENV['AWS_ACCESS_KEY_ID'] 
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']#
    

    aws.instance_type = "m3.xlarge"
    aws.ami = "ami-1da58a77"
    aws.region = "us-east-1"
    aws.security_groups = ["vagrant"]

    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = ENV['AWS_PRIVATE_KEY_PATH']
    # prefer rsync
    override.nfs.functional = false
  end
  
  config.vm.define "zookeeper" do |zookeeper|
    zookeeper.vm.provider :aws do |aws, override|
      hostname = "zookeeper.#{aws_route53_domain}"
      override.dns.record_sets = [[aws_route53_zone, hostname, "A"]]
    end
    zookeeper.vm.provision "shell", path: "install-zookeeper.sh"
  end
  
  config.vm.define "nimbus" do |nimbus|
    hostname = "nimbus.#{aws_route53_domain}"
    nimbus.vm.provider :aws do |aws, override|
      override.dns.record_sets = [[aws_route53_zone, hostname, "A"]]
    end
    
    nimbus.vm.provision "shell", path: "install-storm.sh", args: [STORM_VERSION, hostname]
    nimbus.vm.provision "shell", path: "config-supervisord.sh", args: "nimbus"
    nimbus.vm.provision "shell", path: "config-supervisord.sh", args: "ui"
    nimbus.vm.provision "shell", path: "config-supervisord.sh", args: "drpc"
    nimbus.vm.provision "shell", path: "config-supervisord.sh", args: "logviewer"
    nimbus.vm.provision "shell", path: "start-supervisord.sh"
  end
  
  
  (1..STORM_SUPERVISOR_COUNT).each do |n|
    config.vm.define "supervisor#{n}" do |supervisor|
      hostname = "supervisor#{n}.#{aws_route53_domain}"
      supervisor.vm.provider :aws do |aws, override|
        override.dns.record_sets = [[aws_route53_zone, hostname, "A"]]
      end
      
      supervisor.vm.provision "shell", path: "install-storm.sh", args: [STORM_VERSION, hostname]
      supervisor.vm.provision "shell", path: "config-supervisord.sh", args: "supervisor"
      supervisor.vm.provision "shell", path: "config-supervisord.sh", args: "logviewer"
      # supervisor.vm.provision "shell", path: "config-supervisord.sh", args: "nimbus"
      supervisor.vm.provision "shell", path: "start-supervisord.sh"
      
    end
  end
  
  
  
end
