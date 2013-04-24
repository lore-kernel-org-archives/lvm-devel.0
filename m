From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 24 Apr 2013 20:58:31 +0200
Subject: dmevent plugin
In-Reply-To: <87vc7c1x1z.fsf@in.ibm.com>
References: <87y5c914n6.fsf@in.ibm.com> <5176DAF1.6010301@redhat.com>
	<87vc7c1x1z.fsf@in.ibm.com>
Message-ID: <51782B57.907@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 24.4.2013 04:28, M. Mohan Kumar napsal(a):
> Zdenek Kabelac <zkabelac@redhat.com> writes:
>
>> Dne 23.4.2013 20:30, M. Mohan Kumar napsal(a):
>>> Hello,
>>>
> Zdenek, thanks for the response.
>
>>> As per my understanding lvm2 does not support other applications to
>>> register with dmevent daemon to handle events generated in interested
>>
>> there was at least one non-lvm plugin from dmraid project.
>>
>> dmeventd test is based on 'dmsetup status' - and the plugin is executing
>> lvm code only in case something triggers this action (i.e. fill over
>> threshold) - but since lvm library is not threadsafe - only one plugin
>> could execute lvm code within mutex.
>>
> Yes, the plugins execute interested commands/actions only when a
> specific event is generated, in thin pool case when it reaches the
> threshold.


So if you need to execute different code - you may just duplicate the code,
and replace the executable action with different code.

Currently the executed code in the plugin is not configurable.

On the other hand - you may write your own watching daemon - just
by polling and reading dmsetup status info even in a shell script.

Dmeventd is doing more things - but the main part is to be usable
on /root volumes - but since this is not your case, you may
write easily your own code to watching for pool limits.

>>> devices. Function monitor_dev_for_events() in lib/activate/activate.c
>>> registers with the default events library (if its available).
>>>
>>> When a dm-thinpool is created from SAN[1] and typically multiple hosts have
>>> visibility to the same dm-thinpool. In this case there are chances that
>>> more than one dm-eventd thin plugin will be registered to monitor
>>> it. When dm-thinpool reaches low water mark threshold, these plugins try
>>> to resize the thin-pool causing simultaneous block allocate requests and
>>> dm-thin-pool module may not be capable to handle this situation.
>>
>> dmeventd plugin for lvm thin pool is essentially calling command:
>>
>> 'lvextend --usepolicies'
>>
>> when dmsetup status is report values above threashold.
>>
> When I last checked 'lvextend' did not have --usepolicy option
> enabled. Only lvconvert has this option, so even with thin plugin the
> pool is not resized when it reached threshold. I have to patch thin
> plugin to run lvresize command to increase the pool size and it worked.

yep -  missing in man page, but it's there for quite long time.

>
>>> By using GlusterFS and BD xlator[2] we are planning to use dm-thinpool
>>> to provide thin provisioned storage for hosting the VM images. This pool
>>> could come from a SAN box but there will be a 1:1 mapping between
>>> Glusterfs server and dm-thinpool. It provides controlled clustered
>>> access to dm-thinpool when various Glusterfs clients access the same
>>> dm-thinpool through single GlusterFS server. The idea is to extend the
>>> dm-thinpool(when low water mark threshold reached) from respective
>>> GlusterFS server so that there is only one entity controlling that
>>> dm-thinpool in a clustered environment.
>>
>> There is work-in-progress for clustered usage of thin pools.
>>
> Could you give some pointers to this work, like whats the current
> status, target date et?

I'd estimate half year for some initial release. But currently there are only
some basic ideas for implementation of the proof-of-concept.
But it's hard to say whether it would be usable for anything mentioned here.


>> All LVs have monitoring feature so you could always disable monitoring
>> for particular LV - is that what you mean ?
>>
> Yeah, as a prerequisite we can ask users to disable monitoring
> interested thin pool. But user has to do that in all nodes that are
> connected to SAN, so I expected unless explicitly asked this default
> registration should not happen.

You can easily disable monitoring on all nodes in lvm.conf

Zdenek


