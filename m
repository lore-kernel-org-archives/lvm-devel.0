From: brem belguebli <brem.belguebli@gmail.com>
Date: Sat, 17 Apr 2010 11:15:52 +0200
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
In-Reply-To: <4BC88002.10803@redhat.com>
References: <4BC7817E.7080407@redhat.com>
	<20100415220308.GO13021@agk-dp.fab.redhat.com>
	<4BC88002.10803@redhat.com>
Message-ID: <1271495752.5449.53.camel@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I think things are not clear about this one, and everyone is confused.

Malahal (from IBM) and you have posted a few weeks ago design proposals
and patches to add mirrored log capabilities and also the fact that it
could be located on the mirror legs (pv in our cases) by using
alloc_anywhere.

alloc_anywhere, as described in the man page is to let LVM put the data
logical extents where ever it wants (not strict allocation policy) which
is, in case a mirror is expected completely a nonsense.

You may, (this is a suggestion), when lvcreating a mirror with
mirrored-log
- force strict allocation for the LE's (otherwise it' nonsense)
- put the mirrored log leg on each PV
- And may be disable alloc anywhare when creating mirrors ?

I may miss some cases (more that 2 data devices for RAID 1....)

Regards      

On Fri, 2010-04-16 at 11:19 -0400, Takahiro Yasui wrote:
> On 04/15/10 18:03, Alasdair G Kergon wrote:
> > On Thu, Apr 15, 2010 at 05:13:34PM -0400, Takahiro Yasui wrote:
> >> I tested the latest lvm2 and found that mirror legs were allocated
> >> in the same PV when "--alloc anywhere" was specified. 
> > 
> > That is correct - it is what 'anywhere' means - it is OK for the tools
> > to take the space from 'anywhere'.
> 
> Understand. (I was a bit confused because the behavior of 'anywhere'
> got changed.)
> 
> As for a mirror volume with 'mirrored' log, it is simpler to prepare
> two physical disks and create a mirror volume with 'mirrored log' in
> two disks. In this case, I expect that each disk has one of mirror legs
> one of mirror logs. I was thinking that '--alloc anywhere' was used
> to build this kind of mirror volumes.
> 
> This is an example case.
> 
> # pvs
>   PV         VG   Fmt  Attr PSize  PFree
>   /dev/sdc   vg00 lvm2 a-   16.00G 16.00G
>   /dev/sdd   vg00 lvm2 a-   16.00G 16.00G
> # lvcreate -m1 -L1g -nlv00 --mirrorlog mirrored --alloc anywhere vg00
>   Logical volume "lv00" created
> # dmsetup ls --tree
> vg00-lv00 (253:5)
>  |-vg00-lv00_mimage_1 (253:4)
>  |  `- (8:32)
>  |-vg00-lv00_mimage_0 (253:3)
>  |  `- (8:32)
>  `-vg00-lv00_mlog (253:2)
>     |-vg00-lv00_mlog_mimage_1 (253:1)
>     |  `- (8:32)
>     `-vg00-lv00_mlog_mimage_0 (253:0)
>        `- (8:48)
> 
> Now I undestand that '--alloc anywhere' is not designed for this purpose
> and we need to use the workaround I described in the previous mail as
> below.
> 
> > The workaround in this case is to create a mirror device with a core
> > log, and then to convert it to a mirror with a disk log.
> 
> 
> > Are there any likely situations where a non-optimal layout is selected
> > with --alloc normal?  If so, can we identify them and find some strategy
> > to handle it e.g. do we need to add another allocation policy 
> > to allow logs on the same PVs as mimages?
> 
> I don't have an issue of '--alloc normal' so far.
> 
> Thanks,
> Taka
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel



