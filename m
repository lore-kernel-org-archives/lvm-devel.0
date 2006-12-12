From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 12 Dec 2006 17:55:47 -0500
Subject: [PATCH LVM2] Use parallel areas constraint for mirror log addition
Message-ID: <457F3373.4090600@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch fixes the problem that lvconvert-ing corelog mirror
to disklog mirror allocates the mirror log on the same device
with the mirror images, which is not good from both performance
and redundancy view point.

Example of "lvs -a -o lv_name,devices" after lvconvert:
  LV             Devices
  lv0            lv0_mimage_0(0),lv0_mimage_1(0)
  [lv0_mimage_0] /dev/mapper/pv0(0)
  [lv0_mimage_1] /dev/mapper/pv1(0)
  [lv0_mlog]     /dev/mapper/pv1(1)

Shell script to reproduce the problem and the sample metadata
is attached for reference.
You can reproduce the problem with just executing the script
without additional parameters.



While this patch fixes the most simple case (i.e. the original
LV is contiguous), there is another problem not yet fixed:
  if the original LV was split into multiple segments,
  the log device allocation only the PVs used for the first segment.
Key to fix the another problem is avoiding all PVs in ah->parallel_areas
for the log device allocation instead of the subset of it.

There were attempts to fix it along with other allocation issues
but not yet accpeted for some reasons.

  [PATCH LVM2 0/2] fix alloc anywhere and addition of disklog
  https://www.redhat.com/archives/linux-lvm/2006-September/msg00108.html

  [PATCH LVM2] (0/12) LVM2 allocation rewrites
  https://www.redhat.com/archives/lvm-devel/2006-October/msg00030.html

I'm trying to find less intrusive approach to fix it.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-use-build_parallel.patch
Type: text/x-patch
Size: 1242 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/7af6aae2/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-addlog-2PV.sh
Type: application/x-sh
Size: 1741 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/7af6aae2/attachment.sh>
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lvm2-addlog-2PV.vg
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/7af6aae2/attachment.ksh>
