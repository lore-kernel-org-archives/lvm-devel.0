From: Eric Ren <zren@suse.com>
Date: Fri, 9 Feb 2018 10:21:42 +0800
Subject: master - pvmove: reinstantiate clustered pvmove
In-Reply-To: <b77058d3-386c-707e-a0e2-ef4f6c3e9ad6@redhat.com>
References: <201802012058.w11KwnMa018375@lists01.pubmisc.prod.ext.phx2.redhat.com>
	<5cecc671-dbc2-c0d7-e1a9-64d4bcb68860@suse.com>
	<d278fca1-00a6-d29b-925f-047aed4c949e@redhat.com>
	<8bec25ed-2510-a31e-ba01-6bfd26257b52@suse.com>
	<b77058d3-386c-707e-a0e2-ef4f6c3e9ad6@redhat.com>
Message-ID: <e26d3670-c6c5-ca07-eaf2-bbb3352bf28f@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdeneck,

Thanks for your kind response!
>> You mean so far pvmove can only work like this:
>>
>> - pvmove on the node that the LV is _not_active, but the LV can
>> ??be active on another node, so that users will not suffer downtime
>> ??issue
>
>
> The problem with just locally active LVs is - they can be active on 
> any node.
>
> Current logic of PV knows only 2 states:
>
> 1. Either set of LVs is active exclusively - then pvmove can run in 
> exclusive (no-clustered) mode locally on 1 node.

Got it. My fault! I meant to use 'vgchange -aey', not 'vgchange -aly'. 
Yeah, it works:

tw1:~ # vgchange -aey vgtest2
 ??? 2 logical volume(s) in volume group "vgtest2" now active
tw1:~ # pvmove /dev/vdb1
 ??? Increasing mirror region size from 0??? to 2.00 KiB
 ??? /dev/vdb1: Moved: 4.17%
 ??? /dev/vdb1: Moved: 38.02%
 ??? /dev/vdb1: Moved: 66.67%
 ??? /dev/vdb1: Moved: 79.56%
 ??? /dev/vdb1: Moved: 100.00%


>
> 2. LVs are active on all nodes - then you need cluster-wide pvmove.

This is the one that seems not work properly for me. As said in my first 
reply, it might be a bug:

"""
GDB it a little bit. The problem seems because:

_pvmove_target_present(cmd, 1)


will always return 0 - "not found".

During one pvmove command, the _pvmove_target_present() is invoked 
twice. At first call,
"segtype->ops->target_present()", i.e _mirrored_target_present() will 
set "_mirrored_checked = 1".

At the second call, _mirrored_target_present() will _not_ go through the 
following code to get the
"_mirror_attributes":
...
even if it is asked to back the "target attributes" by 
_pvmove_target_present(cmd, 1).
As result, _pvmove_target_present(cmd, 1) will always return "0", 
because the "attributes"
is empty.
"""

Could you please have a check there?

Either I used "vgchange -ay vgtest" or "vgchange -asy vgtest" to active 
the LVs on all nodes. It just doesn't work:

"""
tw1:~ # vgchange -asy vgtest2
 ??? 2 logical volume(s) in volume group "vgtest2" now active
tw1:~ # lvs
 ??? LV?? VG????? Attr?????? LSize Pool Origin Data%? Meta%? Move Log 
Cpy%Sync Convert
 ??? lv1? vgtest2 -wi-a----- 2.00g
 ??? lv2? vgtest2 -wi-a----- 1.00g
tw1:~ # pvmove /dev/vdb1
 ??? No data to move for vgtest2.
tw1:~ # pvmove /dev/vdb2
 ??? Cannot move in clustered VG vgtest2, clustered mirror (cmirror) not 
detected and LVs are activated non-exclusively.
tw2:~ # lvs
 ??? LV?? VG????? Attr?????? LSize Pool Origin Data%? Meta%? Move Log 
Cpy%Sync Convert
 ??? lv1? vgtest2 -wi-a----- 2.00g
 ??? lv2? vgtest2 -wi-a----- 1.00g
"""

or

"""
tw1:~ # vgchange -an vgtest2
 ??? 0 logical volume(s) in volume group "vgtest2" now active
tw1:~ # vgchange -ay vgtest2
 ??? 2 logical volume(s) in volume group "vgtest2" now active
tw1:~ # lvs
 ??? LV?? VG????? Attr?????? LSize Pool Origin Data%? Meta%? Move Log 
Cpy%Sync Convert
 ??? lv1? vgtest2 -wi-a----- 2.00g
 ??? lv2? vgtest2 -wi-a----- 1.00g
tw1:~ # pvmove /dev/vdb2
 ??? Cannot move in clustered VG vgtest2, clustered mirror (cmirror) not 
detected and LVs are activated non-exclusively.


tw2:~ # lvs
 ??? LV?? VG????? Attr?????? LSize Pool Origin Data%? Meta%? Move Log 
Cpy%Sync Convert
 ??? lv1? vgtest2 -wi-a----- 2.00g
 ??? lv2? vgtest2 -wi-a----- 1.00g
"""

>
>
> ---
>
>
> But then there is 'fuzzy' world - where LVs are active non-exclusively 
> - but we don't exactly know on how many nodes (we can count them - but 
> it's not currently done this way)
>
> So in this fuzzy world -? lvm2 previously actually tried to active 
> those LVs everywhere - but this was not correct - since if user didn't 
> activated LV
> on node X - lvm2 should not active LV there just because of pvmove.

Got it.

>
>>
>> Do I understand it right?
>>
>> But it still cannot work in such case that doing pvmove the 
>> inactive-LV node.
>
>
> Yep - current lvm2 logic does not allow? pvmoving extents for 
> inactive? LV segments.
>
> My long-term plan is to actually add support for this - as this would 
> effectively resolve several problem - but it's very complicated rework
> internally.

Got it, thanks!

>
>
>>
>> It even cannot work on the node that the LV is exclusively activated:
>> ...
>
> You really need to use? 'exclusively' activated LVs.
>
> -aly is just a local activation (so any node can grab one)
>
> -aey is your wanted exclusive activation you should actually use here.

Yes, I meant -aey, sorry!

>
> Also note - many target type can by activated only exclusively anyway 
> - so they do take exclusive lock for 'local' one anyway.
>
> So it's just? linear/strip + mirror where you can play with real
> cluster-wide multinode activation.

I know as you've told me on IRC times ago, thanks.

>
>>> it still possible we can use such LV for pvmove - although during
>>> pvmove 'restart' it? will be only? 'exclusively' activated.
>>
>> Yes, I also noticed this interesting behavior - I'm doubt that it 
>> might bring
>> trouble in HA cluster if cluster FS is sitting on that LV.
>
> Main question here I'd have is -
>
> Why do you actually need to use? -aly for this case instead of -aey ??

Actually, I am expecting pvmove can be used on LVs that are active on 
all nodes, as
you also mentioned above. "-aly" is my mistake, sorry :)

>
>
> Solving '-aly' properly is not very simple - I'll need to think about
> tree activation logic here for a while.
>
> So is there a case in your? HA setup where you need to activate
> at the same time? LV on both nodes with -aly ?
> (since clearly? -aey will not let you do this).

No, It's not what I am pursuing here. What I expect is:

there should be no downtime during pvmove when I use cluster FS on the LV.

Thanks a lot!
Eric




