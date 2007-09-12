From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 12 Sep 2007 14:19:23 -0400
Subject: [LVM2 PATCH] Fix lvcreate's checking of the number of PVs
Message-ID: <46E82DAB.9080805@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

While not explained in man page, lvcreate can take tags of PVs
as a specification of allocatable PVs.
e.g. if you have 2 MD RAID1 disks and other disks in your vg,
      you can do:
       pvchange --addtag raid1 /dev/md[01]
       lvcreate -L100M -i2 vg @raid1
      instead of 'lvcreate -L100M -i2 vg /dev/md0 /dev/md1'

However, lvcreate checks the number of PVs based on the number of
arguments, so it fails even if the number of PVs for the tag is many
enough.

The same check is done later in the allocation code.
So it's safe to remove the checks here.

A patch to fix this and a reproducer script is attached.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-remove-incorrect-check-of-num-pvs.patch
Type: text/x-patch
Size: 1493 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070912/d5a19f46/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvcreate-pvtags.sh
Type: application/x-sh
Size: 1172 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070912/d5a19f46/attachment.sh>
