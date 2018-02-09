From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 9 Feb 2018 13:05:30 +0100
Subject: master - pvmove: reinstantiate clustered pvmove
In-Reply-To: <e26d3670-c6c5-ca07-eaf2-bbb3352bf28f@suse.com>
References: <201802012058.w11KwnMa018375@lists01.pubmisc.prod.ext.phx2.redhat.com>
	<5cecc671-dbc2-c0d7-e1a9-64d4bcb68860@suse.com>
	<d278fca1-00a6-d29b-925f-047aed4c949e@redhat.com>
	<8bec25ed-2510-a31e-ba01-6bfd26257b52@suse.com>
	<b77058d3-386c-707e-a0e2-ef4f6c3e9ad6@redhat.com>
	<e26d3670-c6c5-ca07-eaf2-bbb3352bf28f@suse.com>
Message-ID: <f3a6de00-6421-9fda-a4ff-3afb2bab0d5e@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 9.2.2018 v 03:21 Eric Ren napsal(a):
> Hi Zdeneck,
> 
> Thanks for your kind response!
>>> You mean so far pvmove can only work like this:
>>>
>>> - pvmove on the node that the LV is _not_active, but the LV can
>>> ??be active on another node, so that users will not suffer downtime
>>> ??issue
>>
>>
>> The problem with just locally active LVs is - they can be active on any node.
>>
>> Current logic of PV knows only 2 states:
>>
>> 1. Either set of LVs is active exclusively - then pvmove can run in 
>> exclusive (no-clustered) mode locally on 1 node.
> 
> Got it. My fault! I meant to use 'vgchange -aey', not 'vgchange -aly'. Yeah, 
> it works:
> 
> tw1:~ # vgchange -aey vgtest2
>  ??? 2 logical volume(s) in volume group "vgtest2" now active
> tw1:~ # pvmove /dev/vdb1
>  ??? Increasing mirror region size from 0??? to 2.00 KiB

^^^^ this is actually somewhat suspicious.... I'll need to check how that 
happens  - it should be at least 1/2 MiB by default I think.


>  ??? /dev/vdb1: Moved: 4.17%
>  ??? /dev/vdb1: Moved: 38.02%
>  ??? /dev/vdb1: Moved: 66.67%
>  ??? /dev/vdb1: Moved: 79.56%
>  ??? /dev/vdb1: Moved: 100.00%
> 
> 
>>
>> 2. LVs are active on all nodes - then you need cluster-wide pvmove.
> 
> This is the one that seems not work properly for me. As said in my first 
> reply, it might be a bug:
> 
> """
> GDB it a little bit. The problem seems because:
> 
> _pvmove_target_present(cmd, 1)
> 
> 
> will always return 0 - "not found".


Do you have 'cmirrord' properly configured & running ?

Can you capture log from this tool (i.e. running in foreground and grabbing 
its output)


>> But then there is 'fuzzy' world - where LVs are active non-exclusively - but 
>> we don't exactly know on how many nodes (we can count them - but it's not 
>> currently done this way)
>>
>> So in this fuzzy world -? lvm2 previously actually tried to active those LVs 
>> everywhere - but this was not correct - since if user didn't activated LV
>> on node X - lvm2 should not active LV there just because of pvmove.
> 
> Got it.

We did some more 'brainstorming' - with a result, that it actually doesn't
matter if LV is activate on more nodes - as long as there is cmirrord running,
and lvm2 is able to activate LV on multiple nodes - it should be always
possible to create proper tree mapping.

But let's just see how it will work in reality - it will require some more 
thinking....

>> Why do you actually need to use? -aly for this case instead of -aey ??
> 
> Actually, I am expecting pvmove can be used on LVs that are active on all 
> nodes, as
> you also mentioned above. "-aly" is my mistake, sorry :)

This case should 'mostly' work - except there are still bugs in proper 
recognizing which LVs can be processed in which mode.

Use may need to run 2 pvmoves - one for  cluster-wide active LVs,
and 2nd. for exclusively activated ones - we can't handle ATM both at once.

Zdenek


