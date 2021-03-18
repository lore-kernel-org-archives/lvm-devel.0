From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 18 Mar 2021 18:15:02 +0000 (GMT)
Subject: main - lvremove: extra code for handling thinpool data
Message-ID: <20210318181502.5DEE43844031@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=22554c3ff0807f62f8fa71faab153958c475028b
Commit:        22554c3ff0807f62f8fa71faab153958c475028b
Parent:        5a73399b73305786b61c8dcc78a76d4319608561
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 13:15:44 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:34:57 2021 +0100

lvremove: extra code for handling thinpool data

Add some extra code to handle differently sized thin-pool
from thin-pool data volume.

ATM this can't really happen, but once we start to use multiple
commits while resizing stacked LV, we may actually get into
the position, where data LV has been already resized,
but thin-pool stayed with old size.

But for now - report difference as internal error.
---
 lib/metadata/lv_manip.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 24a2816ef..803f76052 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1605,6 +1605,21 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 					return_0;
 			}
 
+			if (seg_is_thin_pool(seg)) {
+				/* For some segtypes the size may differ between the segment size and its layered LV
+				 * i.e. thin-pool and tdata.
+				 *
+				 * This can get useful, when we will support multiple commits
+				 * while resizing a stacked LV.
+				 */
+				if (seg->len != seg_lv(seg, 0)->le_count) {
+					seg->len = seg_lv(seg, 0)->le_count;
+					/* FIXME: ATM capture as error as it should not happen. */
+					log_debug(INTERNAL_ERROR "Pool size mismatched data size for %s",
+						  display_lvname(seg->lv));
+				}
+			}
+
 			dm_list_del(&seg->list);
 			reduction = seg->len;
 		} else


