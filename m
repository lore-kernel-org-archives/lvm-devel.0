From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Apr 2008 12:56:35 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c lib/loc ...
Message-ID: <20080409125635.26515.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-09 12:56:34

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c locking.h 
	tools          : lvconvert.c polldaemon.h pvmove.c 

Log message:
	Use clustered mirror log with pvmove in clustered VGs, if available.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.836&r2=1.837
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/WHATS_NEW	2008/04/09 12:45:32	1.836
+++ LVM2/WHATS_NEW	2008/04/09 12:56:34	1.837
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Use clustered mirror log with pvmove in clustered VGs, if available.
   Fix some pvmove error status codes.
   Fix vgsplit error paths to release vg_to lock.
   Indicate whether or not VG is clustered in vgcreate log message.
--- LVM2/lib/locking/locking.c	2008/04/07 19:17:29	1.45
+++ LVM2/lib/locking/locking.c	2008/04/09 12:56:34	1.46
@@ -412,19 +412,23 @@
 }
 
 /* Lock a list of LVs */
-int activate_lvs_excl(struct cmd_context *cmd, struct list *lvs)
+int activate_lvs(struct cmd_context *cmd, struct list *lvs, unsigned exclusive)
 {
 	struct list *lvh;
 	struct lv_list *lvl;
 
 	list_iterate_items(lvl, lvs) {
-		if (!activate_lv_excl(cmd, lvl->lv)) {
+		if (!exclusive) {
+			if (!activate_lv(cmd, lvl->lv)) {
+				log_error("Failed to activate %s", lvl->lv->name);
+				return 0;
+			}
+		} else if (!activate_lv_excl(cmd, lvl->lv)) {
 			log_error("Failed to activate %s", lvl->lv->name);
 			list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = list_item(lvh, struct lv_list);
 				activate_lv(cmd, lvl->lv);
 			}
-
 			return 0;
 		}
 	}
--- LVM2/lib/locking/locking.h	2007/11/15 21:30:52	1.37
+++ LVM2/lib/locking/locking.h	2008/04/09 12:56:34	1.38
@@ -120,7 +120,7 @@
 /* Process list of LVs */
 int suspend_lvs(struct cmd_context *cmd, struct list *lvs);
 int resume_lvs(struct cmd_context *cmd, struct list *lvs);
-int activate_lvs_excl(struct cmd_context *cmd, struct list *lvs);
+int activate_lvs(struct cmd_context *cmd, struct list *lvs, unsigned exclusive);
 
 /* Interrupt handling */
 void sigint_clear(void);
--- LVM2/tools/lvconvert.c	2008/04/07 10:23:47	1.62
+++ LVM2/tools/lvconvert.c	2008/04/09 12:56:34	1.63
@@ -258,7 +258,7 @@
 				    struct volume_group *vg __attribute((unused)),
 				    struct logical_volume *lv __attribute((unused)),
 				    struct list *lvs_changed __attribute((unused)),
-				    int first_time __attribute((unused)))
+				    unsigned flags __attribute((unused)))
 {
 	/* lvconvert mirror doesn't require periodical metadata update */
 	return 1;
--- LVM2/tools/polldaemon.h	2008/04/09 12:45:32	1.5
+++ LVM2/tools/polldaemon.h	2008/04/09 12:56:34	1.6
@@ -29,7 +29,7 @@
 	int (*update_metadata) (struct cmd_context *cmd,
 				struct volume_group *vg,
 				struct logical_volume *lv_mirr,
-				struct list *lvs_changed, int first_time);
+				struct list *lvs_changed, unsigned flags);
 	int (*finish_copy) (struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct logical_volume *lv_mirr,
--- LVM2/tools/pvmove.c	2008/04/09 12:45:32	1.51
+++ LVM2/tools/pvmove.c	2008/04/09 12:56:34	1.52
@@ -17,28 +17,43 @@
 #include "polldaemon.h"
 #include "display.h"
 
-static int pvmove_target_present(struct cmd_context *cmd, int clustered)
+#define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
+
+static int _pvmove_target_present(struct cmd_context *cmd, int clustered)
 {
 	const struct segment_type *segtype;
 	unsigned attr = 0;
+	int found = 1;
+	static int _clustered_found = -1;
+
+	if (clustered && _clustered_found >= 0)
+		return _clustered_found;
 
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
 		return_0;
 
 	if (activation() && segtype->ops->target_present &&
-	    !segtype->ops->target_present(NULL, clustered ? &attr : NULL)) {
-		log_error("%s: Required device-mapper target(s) not "
-			  "detected in your kernel", segtype->name);
-		return 0;
-	}
+	    !segtype->ops->target_present(NULL, clustered ? &attr : NULL))
+		found = 0;
 
-	if (clustered && !(attr & MIRROR_LOG_CLUSTERED)) {
-		log_error("%s: Required device-mapper clustered log "
-			  "module not detected in your kernel", segtype->name);
-		return 0;
+	if (activation() && clustered) {
+		if (found && (attr & MIRROR_LOG_CLUSTERED))
+			_clustered_found = found = 1;
+		else
+			_clustered_found = found = 0;
 	}
 
-	return 1;
+	return found;
+}
+
+static unsigned _pvmove_is_exclusive(struct cmd_context *cmd,
+				     struct volume_group *vg)
+{
+	if (vg_status(vg) & CLUSTERED)
+		if (!_pvmove_target_present(cmd, 1))
+			return 1;
+
+	return 0;
 }
 
 /* Allow /dev/vgname/lvname, vgname/lvname or lvname */
@@ -250,10 +265,22 @@
 	return lv_mirr;
 }
 
+static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
+			unsigned exclusive)
+{
+	if (exclusive)
+		return activate_lv_excl(cmd, lv_mirr);
+
+	return activate_lv(cmd, lv_mirr);
+}
+
 static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			    struct logical_volume *lv_mirr,
-			    struct list *lvs_changed, int first_time)
+			    struct list *lvs_changed, unsigned flags)
 {
+	unsigned exclusive = _pvmove_is_exclusive(cmd, vg);
+	unsigned first_time = (flags & PVMOVE_FIRST_TIME) ? 1 : 0;
+
 	log_verbose("Updating volume group metadata");
 	if (!vg_write(vg)) {
 		log_error("ABORTING: Volume group metadata update failed.");
@@ -289,7 +316,7 @@
 	/* Only the first mirror segment gets activated as a mirror */
 	/* FIXME: Add option to use a log */
 	if (first_time) {
-		if (!activate_lv_excl(cmd, lv_mirr)) {
+		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
 			if (!test_mode())
 				log_error("ABORTING: Temporary mirror "
 					  "activation failed.  "
@@ -326,7 +353,8 @@
 	struct list *lvs_changed;
 	struct physical_volume *pv;
 	struct logical_volume *lv_mirr;
-	int first_time = 1;
+	unsigned first_time = 1;
+	unsigned exclusive;
 
 	pv_name_arg = argv[0];
 	argc--;
@@ -359,6 +387,8 @@
 		return ECMD_FAILED;
 	}
 
+	exclusive = _pvmove_is_exclusive(cmd, vg);
+
 	if ((lv_mirr = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
 		log_print("Detected pvmove in progress for %s", pv_name);
 		if (argc || lv_name)
@@ -372,7 +402,7 @@
 		}
 
 		/* Ensure mirror LV is active */
-		if (!activate_lv_excl(cmd, lv_mirr)) {
+		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
 			log_error
 			    ("ABORTING: Temporary mirror activation failed.");
 			unlock_vg(cmd, pv_vg_name(pv));
@@ -416,8 +446,8 @@
 		}
 	}
 
-	/* Lock lvs_changed for exclusive use and activate (with old metadata) */
-	if (!activate_lvs_excl(cmd, lvs_changed)) {
+	/* Lock lvs_changed and activate (with old metadata) */
+	if (!activate_lvs(cmd, lvs_changed, exclusive)) {
 		stack;
 		unlock_vg(cmd, pv_vg_name(pv));
 		return ECMD_FAILED;
@@ -429,7 +459,7 @@
 
 	if (first_time) {
 		if (!_update_metadata
-		    (cmd, vg, lv_mirr, lvs_changed, first_time)) {
+		    (cmd, vg, lv_mirr, lvs_changed, PVMOVE_FIRST_TIME)) {
 			stack;
 			unlock_vg(cmd, pv_vg_name(pv));
 			return ECMD_FAILED;
@@ -565,8 +595,10 @@
 	char *colon;
 	int ret;
 
-	if (!pvmove_target_present(cmd, 0)) {
-		stack;
+	/* dm raid1 target must be present in every case */
+	if (!_pvmove_target_present(cmd, 0)) {
+		log_error("Required device-mapper target(s) not "
+			  "detected in your kernel");
 		return ECMD_FAILED;
 	}
 


