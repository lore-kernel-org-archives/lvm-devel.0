From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 16 Apr 2010 11:19:30 -0400
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
In-Reply-To: <20100415220308.GO13021@agk-dp.fab.redhat.com>
References: <4BC7817E.7080407@redhat.com>
	<20100415220308.GO13021@agk-dp.fab.redhat.com>
Message-ID: <4BC88002.10803@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/15/10 18:03, Alasdair G Kergon wrote:
> On Thu, Apr 15, 2010 at 05:13:34PM -0400, Takahiro Yasui wrote:
>> I tested the latest lvm2 and found that mirror legs were allocated
>> in the same PV when "--alloc anywhere" was specified. 
> 
> That is correct - it is what 'anywhere' means - it is OK for the tools
> to take the space from 'anywhere'.

Understand. (I was a bit confused because the behavior of 'anywhere'
got changed.)

As for a mirror volume with 'mirrored' log, it is simpler to prepare
two physical disks and create a mirror volume with 'mirrored log' in
two disks. In this case, I expect that each disk has one of mirror legs
one of mirror logs. I was thinking that '--alloc anywhere' was used
to build this kind of mirror volumes.

This is an example case.

# pvs
  PV         VG   Fmt  Attr PSize  PFree
  /dev/sdc   vg00 lvm2 a-   16.00G 16.00G
  /dev/sdd   vg00 lvm2 a-   16.00G 16.00G
# lvcreate -m1 -L1g -nlv00 --mirrorlog mirrored --alloc anywhere vg00
  Logical volume "lv00" created
# dmsetup ls --tree
vg00-lv00 (253:5)
 |-vg00-lv00_mimage_1 (253:4)
 |  `- (8:32)
 |-vg00-lv00_mimage_0 (253:3)
 |  `- (8:32)
 `-vg00-lv00_mlog (253:2)
    |-vg00-lv00_mlog_mimage_1 (253:1)
    |  `- (8:32)
    `-vg00-lv00_mlog_mimage_0 (253:0)
       `- (8:48)

Now I undestand that '--alloc anywhere' is not designed for this purpose
and we need to use the workaround I described in the previous mail as
below.

> The workaround in this case is to create a mirror device with a core
> log, and then to convert it to a mirror with a disk log.


> Are there any likely situations where a non-optimal layout is selected
> with --alloc normal?  If so, can we identify them and find some strategy
> to handle it e.g. do we need to add another allocation policy 
> to allow logs on the same PVs as mimages?

I don't have an issue of '--alloc normal' so far.

Thanks,
Taka


