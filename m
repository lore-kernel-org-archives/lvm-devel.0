From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 08 Jan 2007 12:11:24 -0500
Subject: [LVM2 PATCH] (1/5) Separate mirror log allocation from _alloc_parallel_areas()
In-Reply-To: <45A2751E.5010707@ce.jp.nec.com>
References: <45A2751E.5010707@ce.jp.nec.com>
Message-ID: <45A27B3C.7070301@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch moves the log allocation part from _alloc_parallel_area().
Preparation for the following patches.
No functional change.

  - _alloc_parallel_area() doesn't need to allocate struct alloced_area
    for log_area because it's pre-allocated in struct alloc_handle.

  - consume_pv_area() has been done in the separate loop from
    the loop for struct alloced_area setup.
    However, consume_pv_area() just updates given pv_area and
    pv_areas in areas[] are different each other.
    So it can be done in the same loop with the struct alloced_area setup.

  - ah->total_area_len, area_len, *ix and ah->area_multiple are not
    used/updated in log_area allocation.
    So operation on them can be moved before _alloc_log_area().

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: 01-separate-mirror-log-allocation-from-alloc_parallel_area.patch
Type: text/x-patch
Size: 2553 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070108/2d91c213/attachment.bin>
