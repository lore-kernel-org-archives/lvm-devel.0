From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 28 Jan 2015 12:45:59 +0000 (UTC)
Subject: master - cleanup: use macro lv_is_visible()
Message-ID: <20150128124559.3721460314@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2d3f0d747a509178a46f85b6384febde063c633
Commit:        d2d3f0d747a509178a46f85b6384febde063c633
Parent:        553f37da71fecd167fd97b26a33c341b8cba485a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 28 13:34:12 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 28 13:45:27 2015 +0100

cleanup: use macro lv_is_visible()

---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 015af5b..dcb2c5d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2295,7 +2295,7 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 			 * is used in the CTR table.
 			 */
 			if ((seg_type(seg, s) == AREA_UNASSIGNED) ||
-			    ((seg_lv(seg, s)->status & VISIBLE_LV) &&
+			    (lv_is_visible(seg_lv(seg, s)) &&
 			     !(seg_lv(seg, s)->status & LVM_WRITE))) {
 				/* One each for metadata area and data area */
 				if (!dm_tree_node_add_null_area(node, 0) ||


