From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 12 Dec 2006 17:54:23 -0500
Subject: [PATCH LVM2] set stripes = 0 for the log device only allocation
Message-ID: <457F331F.2020906@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch fixes the allocation failure at adding mirror log
if there is only one PV available.


In lib/metadata/lv_manip.c:_allocate(), the number of stripes
is used for calculation of the number of necessary PVs.
    if (areas_size < ah->area_count + ah->log_count) {

On the other hand, lvconvert gives stripes = 1 even if the
allocation request is for log device only.

As a result, the check above will fail if there is only one
PV available and the command will fail as followings:
  Not enough PVs with free space available for parallel allocation.

even though the log device should be allocated from the free PV
without problem.

For log-only allocation, don't give stripes = 1 to the allocator.
The stripes value is considered to be the number of stripes
for which the allocation is requested. (i.e. ah->area_count)


Patch applicable to LVM2 2.02.16.
The patch depends on safe-area_multiple.patch for correct handling
of stripes = 0 by the allocator.

Shell script to reproduce the problem and the sample metadata
is attached for reference.
You can reproduce the problem with just executing the script
without additional parameters.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: set-stripes-0-for-log-alloc.patch
Type: text/x-patch
Size: 1330 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/6f090191/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-logalloc-from-only-one-free-PV.sh
Type: application/x-sh
Size: 2304 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/6f090191/attachment.sh>
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lvm2-logalloc-from-only-one-free-PV.vg
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/6f090191/attachment.ksh>
