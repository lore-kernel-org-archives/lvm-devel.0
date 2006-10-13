From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 16:59:12 -0400
Subject: [PATCH LVM2] (5/12) allow preference to small area
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <452FFE20.3090304@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch allows allocation request to prefer small area.

o _comp_area_inv() is used to reverse the areas[] sorting
  if the allocation request is ALLOC_PREFER_SMALL.

o In _find_parallel_space(), iteration for pv_area didn't work
  work as commented:
                /*
                 * Put the smallest area of each PV that is at least the
                 * size we need into areas array.  If there isn't one
                 * that fits completely and we're allowed more than one
                 * LV segment, then take the largest remaining instead.
                 */
  because of the "goto next_pv" at the end.


$ diffstat -p1 05.prefer_small.patch
 lib/metadata/lv_manip.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)


Thanks,
--
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 05.prefer_small.patch
Type: text/x-patch
Size: 1204 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/46931535/attachment.bin>
