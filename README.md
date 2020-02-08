# k8s "The Hard Way" on Vagrant and Virtual Box

This repo implements the instructions in this repo : https://github.com/kelseyhightower/kubernetes-the-hard-way. Instead of using GCP it uses Vagrant and VirtualBox.

As currently configured it spins up 7 vms, a load-balancer, 3 controllers and 3 workers. As currently configured it uses 36GB of RAM, but could be confiured to use much less. See the settings in [cluster/vagrantFile](cluster/vagrantFile).

