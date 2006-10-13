From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 16:55:00 -0400
Subject: [PATCH LVM2] (1/12) add flattened index to _for_each_pv()
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <452FFD24.9070403@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds "flattened index" to _for_each_pv().

o Using this index, you can map the stacked LV segment into
  the array of PVs.
  This is useful for allocation code to find index of areas[]
  corresponding to the prev_lvseg.

o _for_each_pv() doesn't execute call back function if it's NULL.
  It's useful if you just need to count the number of PVs.
  (_count_parallel_areas).

o The patch adds "start_index" and "end_index" to restrict
  the function call back while maintaining the flattened index.

o Also the patch adds "walk_log_lv" flag instead of reusing
  !only_single_area_segments as workaround, because it is no
  longer correct.


$ diffstat -p1 01.for_each_pv.patch
 lib/metadata/lv_manip.c |   76 ++++++++++++++++++++++++++++++++++++---------
 1 file changed, 57 insertions(+), 19 deletions(-)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


-------------- next part --------------
A non-text attachment was scrubbed...
Name: 01.for_each_pv.patch
Type: text/x-patch
Size: 6128 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/01cbc088/attachment.bin>
