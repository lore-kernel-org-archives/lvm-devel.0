From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 24 Jun 2010 12:40:42 -0400
Subject: [PATCH] lvm2: honor yes and force option by lvconvert
Message-ID: <4C238A8A.50708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch suppresses a following prompt by lvconvert command
when --yes or --force option is specified. 

Full resync required to convert inactive mirror <lv> to core log. Proceed? [y/n]:

This change is useful when lvconvert command is used in a script
and a test case.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/mirror.c            |    5 +++--
 tools/lvconvert.c                |    4 +++-
 3 files changed, 7 insertions(+), 4 deletions(-)

Index: LVM2-2.02.68/lib/metadata/metadata-exported.h
===================================================================
--- LVM2-2.02.68.orig/lib/metadata/metadata-exported.h
+++ LVM2-2.02.68/lib/metadata/metadata-exported.h
@@ -779,7 +779,7 @@ int add_mirror_images(struct cmd_context
 struct logical_volume *detach_mirror_log(struct lv_segment *seg);
 int attach_mirror_log(struct lv_segment *seg, struct logical_volume *lv);
 int remove_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
-		      struct dm_list *removable_pvs);
+		      struct dm_list *removable_pvs, int force);
 int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t log_count, uint32_t region_size,
 		   struct dm_list *allocatable_pvs, alloc_policy_t alloc);
Index: LVM2-2.02.68/lib/metadata/mirror.c
===================================================================
--- LVM2-2.02.68.orig/lib/metadata/mirror.c
+++ LVM2-2.02.68/lib/metadata/mirror.c
@@ -1517,7 +1517,8 @@ int add_mirrors_to_segments(struct cmd_c
  */
 int remove_mirror_log(struct cmd_context *cmd,
 		      struct logical_volume *lv,
-		      struct dm_list *removable_pvs)
+		      struct dm_list *removable_pvs,
+		      int force)
 {
 	float sync_percent;
 	percent_range_t percent_range = PERCENT_0;
@@ -1541,7 +1542,7 @@ int remove_mirror_log(struct cmd_context
 		log_error("Unable to convert the log of an inactive "
 			  "cluster mirror, %s", lv->name);
 		return 0;
-	} else if (yes_no_prompt("Full resync required to convert "
+	} else if (force || yes_no_prompt("Full resync required to convert "
 				 "inactive mirror %s to core log. "
 				 "Proceed? [y/n]: ", lv->name) == 'y')
 		sync_percent = 0;
Index: LVM2-2.02.68/tools/lvconvert.c
===================================================================
--- LVM2-2.02.68.orig/tools/lvconvert.c
+++ LVM2-2.02.68/tools/lvconvert.c
@@ -719,7 +719,9 @@ static int _lv_update_log_type(struct cm
 
 	/* Remove an existing log completely */
 	if (!log_count) {
-		if (!remove_mirror_log(cmd, original_lv, operable_pvs))
+		if (!remove_mirror_log(cmd, original_lv, operable_pvs,
+				       arg_count(cmd, yes_ARG) ||
+				       arg_count(cmd, force_ARG)))
 			return_0;
 		return 1;
 	}


