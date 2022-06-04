From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Sat, 4 Jun 2022 10:23:46 +0530
Subject: lvmthin with dedicated lvols for data/md
Message-ID: <CAFe+wq0kVFovJP7YdkJ3yY0oqdSAHM-St_LbbUFN2dNx6V6gAA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Team!
Good day to you all.

I am setting up a dmthin volume from dedicated disks for data and metadata.
But I am having trouble using the full device and cannot figure out how to
make disk utilization optimal.

For the purpose of testing, I have the following disks.
1/ data device - /dev/md127
2/ metadata device - /dev/sdc2

I follow the below steps to use the full volume but end up with no free
extents in the volume group during the final lvconvert phase to thin-pool.

a) vgcreate test /dev/md127 /dev/sdc2
b) lvcreate -l 100%PVS -n thindata test /dev/md127
c) lvcreate -l 100%PVS -n thinmeta test /dev/sdc2
d) lvconvert --type thin-pool --poolmetadata test/thinmeta test/thindata
The last command fails with insufficient free space in the volume group.

The only way to overcome this is to underutilize the PV during lv creation
in steps b and c above. But the percent usage is dependent on the size of
the disk, whose size will be known only during deployment.

Why does vg need free space to perform lvconvert above in step (d).
How can I ensure dedicated disks provided for data and metadata gets
maximally utilized?
What is the proper workflow here to get this done to meet above goals?


**Logs below**
# vgcreate test /dev/md127 /dev/sdc2
  Physical volume "/dev/md127" successfully created.
  Physical volume "/dev/sdc2" successfully created.
  Volume group "test" successfully created
# vgs
  VG   #PV #LV #SN Attr   VSize   VFree
  test   2   0   0 wz--n- <19.30g <19.30g
# lvcreate -l 100%PVS -n thindata pwx0 /dev/md127
  Volume group "pwx0" not found
  Cannot process volume group pwx0
# lvcreate -l 100%PVS -n thindata test /dev/md127
  Logical volume "thindata" created.
root at bionic:/home/lns/srcs/src/github.com/portworx/porx/bugs# lvcreate -l
100%PVS -n thinmeta test /dev/sdc2
  Logical volume "thinmeta" created.
# lvconvert --type thin-pool --poolmetadata test/thinmeta test/thindata
  Thin pool volume with chunk size 64.00 KiB can address@most 15.81 TiB
of data.
  WARNING: Converting test/thindata and test/thinmeta to thin pool's data
and metadata volumes with metadata wiping.
  THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)
Do you really want to convert test/thindata and test/thinmeta? [y/n]: y
  Volume group "test" has insufficient free space (0 extents): 2383
required.
# vgs
  VG   #PV #LV #SN Attr   VSize   VFree
  test   2   2   0 wz--n- <19.30g    0
#
**Logs end**

Best regards
LN
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220604/3247f369/attachment.htm>
