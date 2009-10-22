From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 22 Oct 2009 16:50:26 -0500
Subject: [PATCH]: Enable snapshots of mirrors
In-Reply-To: <20091022194532.GE10165@agk-dp.fab.redhat.com>
References: <1256237661.14726.3.camel@hydrogen.msp.redhat.com>
	<20091022194532.GE10165@agk-dp.fab.redhat.com>
Message-ID: <480ED1EC-3EB5-494E-9C75-85AFE6075466@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Oct 22, 2009, at 2:45 PM, Alasdair G Kergon wrote:

> On Thu, Oct 22, 2009 at 01:54:21PM -0500, Jon Brassow wrote:
>> pv*:
>> - commands ignored
>
> pvmove is the only one to test I think and it ought to be OK, still
> refusing to let you manipulate any devices concerned.

yup, pvmove skips over the mirrors and the snapshots of the mirror.

>
>> vgck:
>> + seems to work, but I didn't try corrupting the VG
>
> vgck already gives incorrect exit status anyway, someone pointed
> out this week...
>
>> vg*:
>> - other vg commands/options ignored
>
> I'd want to know that vgmerge and vgsplit always behave correctly and
> understand the entire 'stack' of objects must remain together and give
> sensible error messages/deal with name conflicts properly in the  
> various
> different cases.

vgsplit does not allow PVs with mirrors or snapshots to move - "Can't  
split mirror/snapshot between two Volume Groups", but it does allow  
other PVs to move.

vgmerge allows VGs with and without snapshotted mirrors to be merged  
into VGs that do and don't have other LVs.

>
>> lvchange:
>> + '-an' of mirror properly shuts down snapshots too
>> + '-ay' of mirror properly starts up snapshots too
>> + '-a[ny]' of snapshot gives proper error message
>> + '--resync' of mirror origin properly resync's it
>> - other options ignored
>
> check permissions-handling too and --refresh and readahead setting
> propagation.

cursory check of --refresh shows it to work.

+ can't change RW permission of LV under snapshot
+ can change RW permission of snapshot

>
>> lvdisplay:
>> - largely ignored because I'm not familiar with normal output...  
>> but it
>> seems fine
>
> Well, simply, can you easily tell how things are set up from its  
> output,
> or does more descriptive text need to be added?
> (E.g. instead of saying just 'snapshot', saying 'snapshot of mirror')

It just says it is the source of snapshot 'foo' - nothing about  
mirror, but when I remove the snapshot, it doesn't say anything about  
it being mirrored either.

> Most of this code was written with stacked devices in mind, but this  
> is
> the first time we'll actually be turning on and using these code  
> paths.

Sure.  Let me know if you are satisfied with this basic level of  
testing, and I will check it in.

  brassow


