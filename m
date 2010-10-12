From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Oct 2010 16:41:20 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20101012164120.31556.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-12 16:41:18

Modified files:
	lib/metadata   : metadata-exported.h mirror.c 
	tools          : lvconvert.c 

Log message:
	Make lvconvert respect --yes/--force in the inactive log conversion
	prompt. Fixes BZs 642055, 621281. Patch by Taka.
	
	Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.168&r2=1.169
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147

--- LVM2/lib/metadata/metadata-exported.h	2010/09/30 13:05:45	1.168
+++ LVM2/lib/metadata/metadata-exported.h	2010/10/12 16:41:17	1.169
@@ -652,7 +652,7 @@
 struct logical_volume *detach_mirror_log(struct lv_segment *seg);
 int attach_mirror_log(struct lv_segment *seg, struct logical_volume *lv);
 int remove_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
-		      struct dm_list *removable_pvs);
+		      struct dm_list *removable_pvs, int force);
 int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t log_count, uint32_t region_size,
 		   struct dm_list *allocatable_pvs, alloc_policy_t alloc);
--- LVM2/lib/metadata/mirror.c	2010/08/17 19:25:05	1.134
+++ LVM2/lib/metadata/mirror.c	2010/10/12 16:41:17	1.135
@@ -1573,7 +1573,8 @@
  */
 int remove_mirror_log(struct cmd_context *cmd,
 		      struct logical_volume *lv,
-		      struct dm_list *removable_pvs)
+		      struct dm_list *removable_pvs,
+		      int force)
 {
 	float sync_percent;
 	percent_range_t percent_range = PERCENT_0;
@@ -1597,7 +1598,7 @@
 		log_error("Unable to convert the log of an inactive "
 			  "cluster mirror, %s", lv->name);
 		return 0;
-	} else if (yes_no_prompt("Full resync required to convert "
+	} else if (force || yes_no_prompt("Full resync required to convert "
 				 "inactive mirror %s to core log. "
 				 "Proceed? [y/n]: ", lv->name) == 'y')
 		sync_percent = 0;
--- LVM2/tools/lvconvert.c	2010/08/17 16:25:35	1.146
+++ LVM2/tools/lvconvert.c	2010/10/12 16:41:18	1.147
@@ -747,7 +747,9 @@
 
 	/* Remove an existing log completely */
 	if (!log_count) {
-		if (!remove_mirror_log(cmd, original_lv, operable_pvs))
+		if (!remove_mirror_log(cmd, original_lv, operable_pvs,
+				       arg_count(cmd, yes_ARG) ||
+				       arg_count(cmd, force_ARG)))
 			return_0;
 		return 1;
 	}


