From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 15 Apr 2010 17:13:34 -0400
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
Message-ID: <4BC7817E.7080407@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair,

I tested the latest lvm2 and found that mirror legs were allocated
in the same PV when "--alloc anywhere" was specified. This happens
for mirrored log as well.

# /sbin/lvm.static version
  LVM version:     2.02.64(1)-cvs (2010-04-14)
  Library version: 1.02.47-cvs (2010-04-14)
  Driver version:  4.11.5
# pvs
  PV         VG   Fmt  Attr PSize  PFree
  /dev/sdc   vg00 lvm2 a-   16.00G 16.00G
  /dev/sdd   vg00 lvm2 a-   16.00G 16.00G
# lvcreate -m1 -L12m -nlv00 --mirrorlog disk --alloc anywhere vg00
  Logical volume "lv00" created
# dmsetup ls --tree
vg00-lv00 (253:3)
 |-vg00-lv00_mimage_1 (253:2)
 |  `- (8:32)
 |-vg00-lv00_mimage_0 (253:1)
 |  `- (8:32)
 `-vg00-lv00_mlog (253:0)
    `- (8:48)

The workaround in this case is to create a mirror device with a core
log, and then to convert it to a mirror with a disk log.

Is "--alloc anywhere" feature still under development? Or is this a
new behavior?

Thanks,
Taka


