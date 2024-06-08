---
author: al
date: 2014-10-23 21:21:51+00:00
layout: post
title: DNS for Your Virtual Machines
categories:
- GNU/Linux
tags:
- DNS
- libvirt
- Linux
---

For me, the holy grail of working with virtual machines is




    
    <code class="prettyprint">$ ssh root@my-vm</code>





I am tired of manually updating /etc/hosts or looking at arp tables1. There's got to be a better way. And there is! Here's how. This works with Fedora 20. Your mileage may vary with other distros.







  1. Read [this article](http://blog.oddbit.com/2013/10/04/automatic-dns-entries-for-libvirt-domains). It will explain the basics, but follow the instructions below because there are a few differences in the process on Fedora.


  2. Add the following line to `/etc/NetworkManager/NetworkManager.conf` under the [main] block:




    
    <code>dns=dnsmasq</code>





This line tells NetworkManager to run a dnsmasq process.






  3. Download [this](https://raw.github.com/awood/virt-utils/master/virt-hosts) script that will take care of writing out a `hosts` style file that dnsmasq will use for name resolution.




    
    <code class="prettyprint">$ curl -o /usr/bin/virt-hosts  https://raw.github.com/awood/virt-utils/master/virt-hosts && chmod 755 /usr/bin/virt-hosts</code>




  4. <code class="prettyprint">$ echo "addn-hosts=/var/lib/libvirt/dnsmasq/default.addnhosts" >> /etc/NetworkManager/dnsmasq.d/virt-hosts</code>





This line tells NetworkManager to add the `default.addnhosts` file to the list of places that dnsmasq looks at for name resolution.




  5. <code class="prettyprint">$ yum install -y incron</code>



  6. <code class="prettyprint">$ systemctl enable incrond.service && systemctl start incrond.service</code>




  7. Set up incron to run `virt-hosts` every time we detect a change in the status of a virtual machine.




    
    <code class="prettyprint">$ echo "/var/lib/libvirt/dnsmasq/default.leases IN_MODIFY /usr/bin/virt-hosts -ur" > /etc/incron.d/virt-hosts</code>



  8. Add the following line to `/etc/sysconfig/network-scripts/ifcfg-em1`




    
    <code>DOMAIN="default.virt"</code>



  9. <code class="prettyprint">$ systemctl restart NetworkManager</code>



  10. <code class="prettyprint">$ ssh root@your-vm</code>






Done!





1 [The arp table solution](http://rwmj.wordpress.com/2010/10/26/tip-find-the-ip-address-of-a-virtual-machine) seems really simple, but half the time my VMs vanish from the arp table and I can't get their IP anymore.
