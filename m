From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 23 Aug 2007 09:52:35 -0400
Subject: [LVM2 PATCH] Rename ambiguous extent-related variables in allocation code
Message-ID: <46CD9123.3040804@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Thanks for private comments to the RFC posted on Aug. 21.

As a first step, this patch only renames the variables,
with 2 exceptions:
  1. 'remaining' in _alloc_parallel_area() is just replaced
     with 'goal_le - *current_le'
  2. Update comments accordingly

No change in the functionality.
The patch is made to applicable to and tested on today's CVS head +
pvmove cleanup patch below.
https://www.redhat.com/archives/lvm-devel/2007-August/msg00068.html
Dependency to the pvmove patch is only about the patch context,
so the change itself is valid without it.

Please consider to apply.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-allocate-rename-extents-variables.patch
Type: text/x-patch
Size: 17951 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070823/3c5f6fbf/attachment.bin>
