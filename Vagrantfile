# Define virtual machine configuration
MACHINES = {
  # Specify VM name "raid-mdadm"
  :"raid-mdadm" => {
              # Define VM box image
              :box_name => "centos/stream10",
              # Specify box version
              :box_version => "20260615.0",
              # Set number of CPU cores
              :cpus => 1,
              # Set allocated RAM in megabytes
              :memory => 2048,
              # VM IP address
              :ip_addr => '192.168.56.10',
    # Additional virtual disks for RAID experiments
    :disks => {
        # Disk 1
        :sata1 => {
            # Virtual disk file
            :dfile => './sata1.vdi',
            # Disk size in MB
            :size => 512,
            # SATA controller port
            :port => 1
        },
        # Disk 2
        :sata2 => {
            :dfile => './sata2.vdi',
            :size => 512,
            :port => 2
        },
        # Disk 3
        :sata3 => {
            :dfile => './sata3.vdi',
            :size => 512,
            :port => 3
        },
        # Disk 4
        :sata4 => {
            :dfile => './sata4.vdi',
            :size => 512,
            :port => 4
        },
        # Disk 5
        :sata5 => {
            :dfile => './sata5.vdi',
            :size => 512,
            :port => 5
        },
        # Disk 6
        :sata6 => {
            :dfile => './sata6.vdi',
            :size => 512,
            :port => 6
        }
              }
                   }
           }

  Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
      # Apply VM configuration
      config.vm.define boxname do |box|
        # Base box
        box.vm.box = boxconfig[:box_name]
        box.vm.box_version = boxconfig[:box_version]
        # Hostname
        box.vm.hostname = boxname.to_s
        # Network
        box.vm.network "private_network", ip: boxconfig[:ip_addr]
        # Provisioning script
        box.vm.provision "shell", path: "raid-mdadm.sh"
        # Extra provisioning
        box.vm.provision "shell", inline: <<-SHELL
          mkdir -p ~root/.ssh
          cp ~vagrant/.ssh/authorized* ~root/.ssh
          dnf update
          dnf install -y epel-release
          dnf makecache
          dnf install -y smartmontools hdparm gdisk
        SHELL
        # VirtualBox provider config
        box.vm.provider "virtualbox" do |v|
          v.memory = boxconfig[:memory]
          v.cpus = boxconfig[:cpus]
          # Flag to check if SATA controller is needed
          needsController = false
          # Create virtual disks if they do not exist yet
          boxconfig[:disks].each do |dname, dconf|
            # Check if disk file already exists
            unless File.exist?(dconf[:dfile])
              # Create fixed-size virtual disk
              v.customize ['createhd',
                '--filename', dconf[:dfile],
                '--variant', 'Fixed',
                '--size', dconf[:size]]
              # Mark that we need to create SATA controller
              needsController = true
            end
          end
          # Create SATA controller if at least one disk was created
          if needsController
            v.customize ["storagectl", :id,
              "--name", "SATA",
              "--add", "sata",
              "--hostiocache", "on" ]
          # Attach all configured disks to SATA controller
          boxconfig[:disks].each do |dname, dconf|
            v.customize ['storageattach', :id,
              '--storagectl', 'SATA',
              '--port', dconf[:port],
              '--device', 0,
              '--type', 'hdd',
              '--medium', dconf[:dfile]]
          end
        end
      end
    end
  end
end
