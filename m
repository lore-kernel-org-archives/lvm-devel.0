From: ben <benscott@nwlink.com>
Date: Thu, 05 Jul 2012 17:04:05 -0700
Subject: lvcreate and raid volume size problem
Message-ID: <2040970.xrSVmVQSQ2@laptop>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I found what may be a small bug in creating raid volumes.

if I start with three pvs with 2364 extents each:

lvs --version
  LVM version:     2.02.95(2) (2012-03-06)
  Library version: 1.02.74 (2012-03-06)
  Driver version:  4.22.0

pvs --units 4m
  PV         VG   Fmt  Attr PSize PFree
  /dev/sdq   vg1  lvm2 a--  2364  2364
  /dev/sdr   vg1  lvm2 a--  2364  2364
  /dev/sds   vg1  lvm2 a--  2364  2364

Since RAID 5 needs a parity stripe and each stripe needs an extent
for metadata I should have 4726 (2 * 2363) extents for a volume.

But, if I run:

lvcreate --stripes 2 --stripesize 64k --type raid5 --extents +4726 vg1 
/dev/sdq /dev/sdr /dev/sds
  Insufficient free space: 7094 extents needed, but only 7092 available

So I run this instead:

lvcreate --stripes 2  --stripesize 64k --type raid5 --extents +4724 vg1 
/dev/sdq /dev/sdr /dev/sds
  Logical volume "lvol0" created

Now I have one free extent on each pv:

pvs --units 4m
  PV         VG   Fmt  Attr PSize    PFree
  /dev/sdq   vg1  lvm2 a--  2364.00U    1.00U
  /dev/sdr   vg1  lvm2 a--  2364.00U    1.00U
  /dev/sds   vg1  lvm2 a--  2364.00U    1.00U

Finally I execute this:

lvextend --stripes 2  --stripesize 64k --type raid5 --extents +2 vg1/lvol0 
/dev/sdq /dev/sdr /dev/sds

Extending logical volume lvol0 to 18.46 GiB
  Failed to find segment for lvol0_rimage_0 extent 4723
  Failed to find segment for lvol0_rimage_0 extent 4723
  Failed to find segment for lvol0_rimage_0 extent 4723
  Failed to find segment for lvol0_rimage_0 extent 4723
  Failed to find segment for lvol0_rimage_0 extent 4723
  Failed to find segment for lvol0_rimage_0 extent 4723
  Logical volume lvol0 successfully resized

pvs --units 4m
  PV         VG   Fmt  Attr PSize    PFree
  /dev/sdq   vg1  lvm2 a--  2364.00U       0U
  /dev/sdr   vg1  lvm2 a--  2364.00U       0U
  /dev/sds   vg1  lvm2 a--  2364.00U       0U


Since my program calls lvcreate, it needs to be able to
determine the maximum lv size, which I am having trouble
with here. If someone could look into this I would
appreciate it.

thank you.


