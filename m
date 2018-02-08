From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 8 Feb 2018 13:42:40 +0100
Subject: master - pvmove: reinstantiate clustered pvmove
In-Reply-To: <8bec25ed-2510-a31e-ba01-6bfd26257b52@suse.com>
References: <201802012058.w11KwnMa018375@lists01.pubmisc.prod.ext.phx2.redhat.com>
	<5cecc671-dbc2-c0d7-e1a9-64d4bcb68860@suse.com>
	<d278fca1-00a6-d29b-925f-047aed4c949e@redhat.com>
	<8bec25ed-2510-a31e-ba01-6bfd26257b52@suse.com>
Message-ID: <b77058d3-386c-707e-a0e2-ef4f6c3e9ad6@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 8.2.2018 v 02:45 Eric Ren napsal(a):
> Hi Zdenek,
> 
> Thanks for your response :)
> 
> On 02/08/2018 12:49 AM, Zdenek Kabelac wrote:
>> Dne 7.2.2018 v 08:17 Eric Ren napsal(a):
>>> Hello Zdenek,
>>>
>>> I've tried this patch with clvmd and cmirrord running, and all LVs in 
>>> clustered VG being activated
>>> on both nodes. But, pvmove still cannot work as expect - move data on 
>>> underlying PV of the the
>>> non-exclusive activated LV.
>>>
>>>
>>> will always return 0 - "not found".
>>>
>>> During one pvmove command, the _pvmove_target_present() is invoked twice. 
>>> At first call,
>>> "segtype->ops->target_present()", i.e _mirrored_target_present() will set 
>>> "_mirrored_checked = 0".
>>>
>>> At the second call, _mirrored_target_present() will not go through the 
>>> following code to get the
>>> "_mirror_attributes":
>>>
>>
>>
>> Hi
>>
>> I think I've intentionally kept away locally active LVs,
> 
> You mean so far pvmove can only work like this:
> 
> - pvmove on the node that the LV is _not_active, but the LV can
>  ?be active on another node, so that users will not suffer downtime
>  ?issue


The problem with just locally active LVs is - they can be active on any node.

Current logic of PV knows only 2 states:

1. Either set of LVs is active exclusively - then pvmove can run in exclusive 
(no-clustered) mode locally on 1 node.

2. LVs are active on all nodes - then you need cluster-wide pvmove.


---


But then there is 'fuzzy' world - where LVs are active non-exclusively - but 
we don't exactly know on how many nodes (we can count them - but it's not 
currently done this way)

So in this fuzzy world -  lvm2 previously actually tried to active those LVs 
everywhere - but this was not correct - since if user didn't activated LV
on node X - lvm2 should not active LV there just because of pvmove.

> 
> Do I understand it right?
> 
> But it still cannot work in such case that doing pvmove the inactive-LV node.


Yep - current lvm2 logic does not allow  pvmoving extents for inactive  LV 
segments.

My long-term plan is to actually add support for this - as this would 
effectively resolve several problem - but it's very complicated rework
internally.


> 
> It even cannot work on the node that the LV is exclusively activated:
> 
> ====
> tw1:~ # vgchange -aly vgtest2
>  ??? 2 logical volume(s) in volume group "vgtest2" now active
> tw2:~ # lvs
>  ??? LV?? VG????? Attr?????? LSize Pool Origin Data%? Meta%? Move Log Cpy%Sync 
> Convert
>  ??? lv1? vgtest2 -wi------- 2.00g
>  ??? lv2? vgtest2 -wi------- 1.00g
> 
> tw1:~ # lvs
>  ??? LV?? VG????? Attr?????? LSize Pool Origin Data%? Meta%? Move Log Cpy%Sync 
> Convert
>  ??? lv1? vgtest2 -wi-a----- 2.00g
>  ??? lv2? vgtest2 -wi-a----- 1.00g
> tw1:~ # pvmove /dev/vdb1
>  ??? Cannot move in clustered VG vgtest2, clustered mirror (cmirror) not 
> detected and LVs are activated non-exclusively.


You really need to use  'exclusively' activated LVs.

-aly is just a local activation (so any node can grab one)

-aey is your wanted exclusive activation you should actually use here.

Also note - many target type can by activated only exclusively anyway - so 
they do take exclusive lock for 'local' one anyway.

So it's just  linear/strip + mirror where you can play with real
cluster-wide multinode activation.

>> it still possible we can use such LV for pvmove - although during
>> pvmove 'restart' it? will be only? 'exclusively' activated.
> 
> Yes, I also noticed this interesting behavior - I'm doubt that it might bring
> trouble in HA cluster if cluster FS is sitting on that LV.

Main question here I'd have is -

Why do you actually need to use  -aly for this case instead of  -aey ??


Solving '-aly' properly is not very simple - I'll need to think about
tree activation logic here for a while.

So is there a case in your  HA setup where you need to activate
at the same time  LV on both nodes with -aly ?
(since clearly  -aey will not let you do this).


Zdenek


