# k8s "The Hard Way" on Vagrant and Virtual Box

This repo implements the instructions in this repo : https://github.com/kelseyhightower/kubernetes-the-hard-way. Instead of using GCP it uses Vagrant and VirtualBox.

As currently configured it spins up 7 vms, a load-balancer, 3 controllers and 3 workers. As currently configured it uses 36GB of RAM, but could be confiured to use much less. See the settings in [cluster/vagrantFile](cluster/vagrantFile).

   * [cluster](cluster/) : contains vagrant and script resources to to spin up the VM cluster, with static IP addresses
      * 192.168.20.10 : haproxy load-balancer and dnsmasq DNS server
      * 192.168.20.[11-13] : kubernetes contollers hosting the API
      * 192.168.20.[21-23] : kubernetes workers that hosts pods with cri-o
   * [cluster/vbox](cluster/vbox) : convenient scrips to create and restore vb snaphots, as initially spining up the VMs is a bit time consuming
   * [cluster/init_scripts](cluster/init_scripts) : scripts that initialise each VM appropriately at start up
   * [certs_config/gen_certs.sh](certs_config/gen_certs.sh) : contains script to generate all the necessary SSL keys and refernceing YAML files for the kbernetes contol planes
   * [etcd](etcd) : scripts to setup and check the status of etcd on the controller VMs
   * [kubernetes/controllers](kubernetes/controllers) : scripts to setup and check the status of the kubernetes control plane
   * [lb](lb) : scripts to setup and check the status of the loadbalancer for the kubernetes API
   * [kubernetes/workers](kubernetes/workers) : scripts to setup and check the status of the kubernetes workers
   * [certs_config/kubectl_setup.sh](certs_config/kubectl_setup.sh) : contains script to configure kubectl on a remote machine
   * [coredns](coredns) : to setup coredns
   * [dashboard](dashboard) : to setup kubernetes dashboard


## To be done

   * Application Ingress
   * User management
   * Storage
