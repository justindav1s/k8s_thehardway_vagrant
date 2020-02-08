# k8s "The Hard Way" on Vagrant and Virtual Box

This repo implements the instructions in this repo : https://github.com/kelseyhightower/kubernetes-the-hard-way. Instead of using GCP it uses Vagrant and VirtualBox.

As currently configured it spins up 7 vms, a load-balancer, 3 controllers and 3 workers. As currently configured it uses 36GB of RAM, but could be confiured to use much less. See the settings in [cluster/vagrantFile](cluster/vagrantFile).

   * [cluster](cluster/) : contains vagrant and script resources to to spin up the VM cluster, with static IP addresses
      * 192.168.20.10 : haproxy load-balancer and dnsmasq DNS server
      * 192.168.20.[11-13] : kubernetes contollers hosting the API
      * 192.168.20.[21-23] : kubernetes workers that hosts pods with cri-o

