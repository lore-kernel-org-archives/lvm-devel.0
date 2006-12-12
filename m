From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 12 Dec 2006 17:54:54 -0500
Subject: [PATCH LVM2] Detect allocation failure of log device
Message-ID: <457F333E.3010600@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch fixes the testing of allocation result
so that it doesn't miss the failure of log device allocation.


Current code only checks whether the number of extents for
normal devices are allocated as requested.
The number of extents allocated for the log device is out of
consideration.

As a result, the allocator returns success and the later operation
to the allocated extents will cause error with misleading error
messages like this:
  LV lv0_mlog: segment 1 has inconsistent PV area 0
  Internal error: LV segments corrupted in lv0_mlog.

We have to check for the case that only the allocation attempt for
the log device failed,


Patch applicable to LVM2 2.02.16.
Shell script to reproduce the problem and the sample metadata
is attached for reference.
You can reproduce the problem with just executing the script
without additional parameters.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: detect-log-only-allocation-failure.patch
Type: text/x-patch
Size: 1056 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/2f0f25b2/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-logonly-alloc-failure.sh
Type: application/x-sh
Size: 2323 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/2f0f25b2/attachment.sh>
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lvm2-logonly-alloc-failure.vg
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/2f0f25b2/attachment.ksh>
