---
author: Tim Bielawa
date: 2013-07-05 21:01:23+00:00
layout: post
title: A Munin plugin for OpenShift
categories:
- GNU/Linux
- Planet
- Tutorials
tags:
- charts
- graphs
- munin
- OpenShift
- Red Hat
---

I created a [munin](http://munin-monitoring.org/) plugin to chart the number of gears present/idle on [OpenShift](https://www.openshift.com/) application node instances. The plugin was written for/tested against [OpenShift Enterprise 1.2](http://www.redhat.com/products/cloud-computing/openshift-enterprise/).


# Chart: One Host


[![Present/Idle gears on a host](http://blog.lnx.cx/wp-content/uploads/2013/07/openshift_gears_present-node01.ose-poc-300x200.png)](http://blog.lnx.cx/wp-content/uploads/2013/07/openshift_gears_present-node01.ose-poc.png)

These charts show the number of gears present/idle on a single OpenShift application node instance. Nothing special required to set this plugin up. Just copy the script/configuration to your node and then restart the **munin-node** service.


# Chart: District


[![Gears present across a district](http://blog.lnx.cx/wp-content/uploads/2013/07/openshift_gears_present-nodes-small.ose-poc-300x190.png)](http://blog.lnx.cx/wp-content/uploads/2013/07/openshift_gears_present-nodes-small.ose-poc.png)

This is a combined/multigraph chart showing the number of gears present on all nodes representing my "small" district. This chart is created using the munin concept of ['loaning' data](http://munin-monitoring.org/wiki/LoaningData).


# GitHub: openshift-munin-plugins


Interested in trying it out yourself? The code is up on github: [tbielawa/openshift-munin-plugins](https://github.com/tbielawa/openshift-munin-plugins).

Along with the actual plugin you can find example munin server configs for creating the multigraph chart of gears across all nodes in a district.
