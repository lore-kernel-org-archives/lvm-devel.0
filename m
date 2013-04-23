From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Wed, 24 Apr 2013 00:00:21 +0530
Subject: dmevent plugin
Message-ID: <87y5c914n6.fsf@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

As per my understanding lvm2 does not support other applications to
register with dmevent daemon to handle events generated in interested
devices. Function monitor_dev_for_events() in lib/activate/activate.c
registers with the default events library (if its available).

When a dm-thinpool is created from SAN[1] and typically multiple hosts have
visibility to the same dm-thinpool. In this case there are chances that
more than one dm-eventd thin plugin will be registered to monitor
it. When dm-thinpool reaches low water mark threshold, these plugins try
to resize the thin-pool causing simultaneous block allocate requests and
dm-thin-pool module may not be capable to handle this situation.

There could be specific applications using this dm-thinpool in a SAN
environment and wanting to handle the dm-thinpool specific events by
themselves.

By using GlusterFS and BD xlator[2] we are planning to use dm-thinpool
to provide thin provisioned storage for hosting the VM images. This pool
could come from a SAN box but there will be a 1:1 mapping between
Glusterfs server and dm-thinpool. It provides controlled clustered
access to dm-thinpool when various Glusterfs clients access the same
dm-thinpool through single GlusterFS server. The idea is to extend the
dm-thinpool(when low water mark threshold reached) from respective
GlusterFS server so that there is only one entity controlling that
dm-thinpool in a clustered environment.

Is there any way to avoid this default registration? So that only
specific applicationcode can register itself with interested dm-thinpool
and take the necessary action when low watermark threshold is reached?

[1] Basic SAN without supporting thin provisioning
[2] http://review.gluster.com/#/c/4714/


