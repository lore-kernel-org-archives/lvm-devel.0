From: Eric Ren <zren@suse.com>
Date: Mon, 30 Oct 2017 12:48:29 +0800
Subject: [PATCH] lvconvert: fix wrong name order when merging thin snapshot
Message-ID: <20171030044829.9564-1-zren@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The wrong message occurs when merging thin snapshot as below:

"""
lvcreate --type thin-pool -l80%FREE -n pool1 vg1
lvcreate -T vg1/pool1 -V 1G -n lv1
mkfs.ext2 /dev/vg1/lv1
mkdir mnt
mount /dev/vg1/lv1 mnt/
touch mnt/foo
lvcreate -s -n lv1.snap1 vg1/lv1
touch mnt/bar
umount mnt
lvconvert --merge vg1/lv1.snap1
  Merging of thin snapshot vg1/lv1 will occur on next activation of vg1/lv1.snap1.
"""

Fix the wrong name order by saving the initial names at the beginning, and
also remove the unnecessary callings to display_lvname().

Signed-off-by: Eric Ren <zren@suse.com>
---
 tools/lvconvert.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 76be5cb..3b2341c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2101,10 +2101,12 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 	int origin_is_active = 0, r = 0;
 	struct lv_segment *snap_seg = first_seg(lv);
 	struct logical_volume *origin = snap_seg->origin;
+	const char *origin_name = display_lvname(origin);
+	const char *snap_name = display_lvname(lv);
 
 	if (!origin) {
 		log_error("%s is not a mergeable logical volume.",
-			  display_lvname(lv));
+			  snap_name);
 		return 0;
 	}
 
@@ -2118,16 +2120,16 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 	if (lv_is_external_origin(origin)) {
 		if (!(origin = origin_from_cow(lv)))
 			log_error(INTERNAL_ERROR "%s is missing origin.",
-				  display_lvname(lv));
+				  snap_name);
 		else
 			log_error("%s is read-only external origin %s.",
-				  display_lvname(lv), display_lvname(origin));
+				  snap_name, origin_name);
 		return 0;
 	}
 
 	if (lv_is_origin(origin)) {
 		log_error("Merging into the old snapshot origin %s is not supported.",
-			  display_lvname(origin));
+			  origin_name);
 		return 0;
 	}
 
@@ -2155,7 +2157,7 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 
 		if (origin_is_active && !activate_lv(cmd, lv)) {
 			log_error("Failed to reactivate origin %s.",
-				  display_lvname(lv));
+				  origin_name);
 			goto out;
 		}
 
@@ -2176,7 +2178,7 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 	if (r)
 		log_print_unless_silent("Merging of thin snapshot %s will occur on "
 					"next activation of %s.",
-					display_lvname(lv), display_lvname(origin));
+					snap_name, origin_name);
 
 	return r;
 }
-- 
2.10.2


