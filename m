From: Eric Ren <zren@suse.com>
Date: Fri, 9 Feb 2018 21:29:33 +0800
Subject: master - pvmove: reinstantiate clustered pvmove
In-Reply-To: <f3a6de00-6421-9fda-a4ff-3afb2bab0d5e@redhat.com>
References: <201802012058.w11KwnMa018375@lists01.pubmisc.prod.ext.phx2.redhat.com>
	<5cecc671-dbc2-c0d7-e1a9-64d4bcb68860@suse.com>
	<d278fca1-00a6-d29b-925f-047aed4c949e@redhat.com>
	<8bec25ed-2510-a31e-ba01-6bfd26257b52@suse.com>
	<b77058d3-386c-707e-a0e2-ef4f6c3e9ad6@redhat.com>
	<e26d3670-c6c5-ca07-eaf2-bbb3352bf28f@suse.com>
	<f3a6de00-6421-9fda-a4ff-3afb2bab0d5e@redhat.com>
Message-ID: <df116b7f-2d69-38aa-a418-95137ba7e9b0@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdeneck,

I tested with LVM 2.02.177, and with the following patches backported:

 ? + 0001-pvmove-fix-_remove_sibling_pvs_from_trim_list.patch
 ? + 0002-pvmove-better-check-for-exclusive-LV.patch
 ? + 0003-pvmove-drop-misleading-pvmove-restriction-for-cluste.patch
 ? + 0004-cleanup-enhance-messages.patch
 ? + 0005-cleanup-drop-unused-code.patch
 ? + 0006-activation-guard-exclusive-activation.patch
 ? + 0007-activation-move-check-later.patch
 ? + 0008-pvmove-reinstantiate-clustered-pvmove.patch

So the problem might be only on my side, if your testing is fine with 
the latest
upstream. I am just waiting for the 2.02.178 to come out and try it again.

I will be on vacation for the coming Chinese New Year. I will try more 
carefully
as you suggested after coming back :)

On 02/09/2018 08:05 PM, Zdenek Kabelac wrote:
> Dne 9.2.2018 v 03:21 Eric Ren napsal(a):
>> Hi Zdeneck,
>>
>> Thanks for your kind response!
>>>> You mean so far pvmove can only work like this:
>>>>
>>>> - pvmove on the node that the LV is _not_active, but the LV can
>>>> ??be active on another node, so that users will not suffer downtime
>>>> ??issue
>>>
>>>
>>> The problem with just locally active LVs is - they can be active on 
>>> any node.
>>>
>>> Current logic of PV knows only 2 states:
>>>
>>> 1. Either set of LVs is active exclusively - then pvmove can run in 
>>> exclusive (no-clustered) mode locally on 1 node.
>>
>> Got it. My fault! I meant to use 'vgchange -aey', not 'vgchange 
>> -aly'. Yeah, it works:
>>
>> tw1:~ # vgchange -aey vgtest2
>> ???? 2 logical volume(s) in volume group "vgtest2" now active
>> tw1:~ # pvmove /dev/vdb1
>> ???? Increasing mirror region size from 0??? to 2.00 KiB
>
> ^^^^ this is actually somewhat suspicious.... I'll need to check how 
> that happens? - it should be at least 1/2 MiB by default I think.

In my lvm.conf:

""""
 ??? # For RAID or 'mirror' segment types, 'raid_region_size' is the
 ??? # size (in KiB) of each:
 ??? # - synchronization operation when initializing
 ??? # - each copy operation when performing a 'pvmove' (using 'mirror' 
segtype)
 ??? # This setting has replaced 'mirror_region_size' since version 2.02.99
 ??? raid_region_size = 512
""""

>
> Do you have 'cmirrord' properly configured & running ?

'cmirrord' and 'clvmd' are running, but I don't know how to configure 
'cmirrord':

"""
tw1:~ # pgrep -a cmirrord
11931 cmirrord
tw1:~ # pgrep -a clvmd
11748 /usr/sbin/clvmd -T90 -d0

"""

>
> Can you capture log from this tool (i.e. running in foreground and 
> grabbing its output)

Hmm, I had a quick testing:

Terminal 1, without anything ouput during pvmove:
"""
tw1:~ # cmirrord -f
Starting cmirrord:
"""

Terminal 2:
"""
tw1:~ # pvmove /dev/vdb2 -v
 ??? ? Cluster mirror log daemon not included in build.
 ??? ? Wiping internal VG cache
 ??? ? Wiping cache of LVM-capable devices
 ??? ? Skipping foreign volume group vgtest3
 ??? ? Archiving volume group "vgtest2" metadata (seqno 25).
 ??? ? Creating logical volume pvmove0
 ??? Cannot move in clustered VG vgtest2, clustered mirror (cmirror) not 
detected and LVs are activated non-exclusively.
"""

Hmm, what does "Cluster mirror log daemon not included in build." mean?

There should be two daemons: cmirrord and the cluster mirror log? I think
cmirrord is Cluster mirror log daemon?

Ah, I think I know what is going wrong... our package team splat 
lvm2.spec into lvm2.spec,
lvm2-clvm.spec and device-mapper.spec.

In lvm2.spec, they don't configure "--enable-cmirrord". Even though they 
have it in lvm2-clvm.spec,
they finally only ships the cluster-related binaries, and drop the main 
'lvm' binary built with "--enable-cmirrord".
I hate that hacking stuff, but...

Sorry for the noise, I will fix up it and try again. Thanks for your help!


>
>
>>> But then there is 'fuzzy' world - where LVs are active 
>>> non-exclusively - but we don't exactly know on how many nodes (we 
>>> can count them - but it's not currently done this way)
>>>
>>> So in this fuzzy world -? lvm2 previously actually tried to active 
>>> those LVs everywhere - but this was not correct - since if user 
>>> didn't activated LV
>>> on node X - lvm2 should not active LV there just because of pvmove.
>>
>> Got it.
>
> We did some more 'brainstorming' - with a result, that it actually 
> doesn't
> matter if LV is activate on more nodes - as long as there is cmirrord 
> running,
> and lvm2 is able to activate LV on multiple nodes - it should be always
> possible to create proper tree mapping.
>
> But let's just see how it will work in reality - it will require some 
> more thinking....
>
>>> Why do you actually need to use? -aly for this case instead of -aey ??
>>
>> Actually, I am expecting pvmove can be used on LVs that are active on 
>> all nodes, as
>> you also mentioned above. "-aly" is my mistake, sorry :)
>
> This case should 'mostly' work - except there are still bugs in proper 
> recognizing which LVs can be processed in which mode.
>
> Use may need to run 2 pvmoves - one for? cluster-wide active LVs,
> and 2nd. for exclusively activated ones - we can't handle ATM both at 
> once.

Thanks!

Regards,
Eric



