From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Apr 2013 21:03:13 +0200
Subject: dmevent plugin
In-Reply-To: <87y5c914n6.fsf@in.ibm.com>
References: <87y5c914n6.fsf@in.ibm.com>
Message-ID: <5176DAF1.6010301@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 23.4.2013 20:30, M. Mohan Kumar napsal(a):
> Hello,
>
> As per my understanding lvm2 does not support other applications to
> register with dmevent daemon to handle events generated in interested

there was at least one non-lvm plugin from dmraid project.

dmeventd test is based on 'dmsetup status' - and the plugin is executing
lvm code only in case something triggers this action (i.e. fill over 
threshold) - but since lvm library is not threadsafe - only one plugin
could execute lvm code within mutex.


> devices. Function monitor_dev_for_events() in lib/activate/activate.c
> registers with the default events library (if its available).
>
> When a dm-thinpool is created from SAN[1] and typically multiple hosts have
> visibility to the same dm-thinpool. In this case there are chances that
> more than one dm-eventd thin plugin will be registered to monitor
> it. When dm-thinpool reaches low water mark threshold, these plugins try
> to resize the thin-pool causing simultaneous block allocate requests and
> dm-thin-pool module may not be capable to handle this situation.

dmeventd plugin for lvm thin pool is essentially calling command:

'lvextend --usepolicies'

when dmsetup status is report values above threashold.


> There could be specific applications using this dm-thinpool in a SAN
> environment and wanting to handle the dm-thinpool specific events by
> themselves.

Code from thin plugin might be easily duplicated and modified.

But since you are repeatedly mentioning  dm-thinpool - it seems like
you do not plan to lvm2 thin support here and you want to create
thin pool natively via dmsetup commands ?

> By using GlusterFS and BD xlator[2] we are planning to use dm-thinpool
> to provide thin provisioned storage for hosting the VM images. This pool
> could come from a SAN box but there will be a 1:1 mapping between
> Glusterfs server and dm-thinpool. It provides controlled clustered
> access to dm-thinpool when various Glusterfs clients access the same
> dm-thinpool through single GlusterFS server. The idea is to extend the
> dm-thinpool(when low water mark threshold reached) from respective
> GlusterFS server so that there is only one entity controlling that
> dm-thinpool in a clustered environment.

There is work-in-progress for clustered usage of thin pools.

> Is there any way to avoid this default registration? So that only

All LVs have monitoring feature so you could always disable monitoring
for particular LV - is that what you mean ?

> specific applicationcode can register itself with interested dm-thinpool
> and take the necessary action when low watermark threshold is reached?
>
> [1] Basic SAN without supporting thin provisioning
> [2] http://review.gluster.com/#/c/4714/
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>

Zdenek


