From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 26 Oct 2010 01:38:00 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c tools/vgchange.c
Message-ID: <20101026013800.22447.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-10-26 01:37:59

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c vgchange.c 

Log message:
	Fix vgchange to process -a, --refresh, --monitor and --poll like lvchange.
	
	Simultaneous -a and --refresh is not valid.
	poll+monitor are valid together with or without -ay* (but not with -an*)
	
	No longer print polling results summary if no LVs in the VG were polled.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1777&r2=1.1778
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/WHATS_NEW	2010/10/25 17:33:51	1.1777
+++ LVM2/WHATS_NEW	2010/10/26 01:37:59	1.1778
@@ -1,5 +1,6 @@
 Version 2.02.76
 ===================================
+  Fix vgchange to process -a, --refresh, --monitor and --poll like lvchange.
   Add lvm2app functions to query any pv, vg, or lv property / report field.
 
 Version 2.02.75 - 25th October 2010
--- LVM2/tools/lvchange.c	2010/08/17 19:25:05	1.125
+++ LVM2/tools/lvchange.c	2010/10/26 01:37:59	1.126
@@ -715,7 +715,7 @@
 
 int lvchange(struct cmd_context *cmd, int argc, char **argv)
 {
-	int update = /* options other than -a, --refresh or --monitor */
+	int update = /* options other than -a, --refresh, --monitor or --poll */
 		arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 		arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 		arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
@@ -732,6 +732,10 @@
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, available_ARG) && arg_count(cmd, refresh_ARG)) {
+		log_error("Only one of -a and --refresh permitted.");
+		return EINVALID_CMD_LINE;
+	}
 
 	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
 	     arg_count(cmd, sysinit_ARG)) && update) {
--- LVM2/tools/vgchange.c	2010/10/25 10:40:13	1.114
+++ LVM2/tools/vgchange.c	2010/10/26 01:37:59	1.115
@@ -180,9 +180,10 @@
 
 	if (lvs_in_vg_activated(vg) && background_polling()) {
 	        polled = _poll_lvs_in_vg(cmd, vg);
-		log_print("Background polling started for %d logical volume(s) "
-			  "in volume group \"%s\"",
-			  polled, vg->name);
+		if (polled)
+			log_print("Background polling started for %d logical volume(s) "
+				  "in volume group \"%s\"",
+				  polled, vg->name);
 	}
 
 	return ECMD_PROCESSED;
@@ -592,13 +593,30 @@
 						arg_int_value(cmd, poll_ARG,
 						DEFAULT_BACKGROUND_POLLING));
 
-	if (arg_count(cmd, available_ARG))
+	if (arg_count(cmd, available_ARG)) {
 		r = _vgchange_available(cmd, vg);
+		if (r != ECMD_PROCESSED)
+			return r;
+	}
+
+	if (arg_count(cmd, refresh_ARG)) {
+		/* refreshes the visible LVs (which starts polling) */
+		r = _vgchange_refresh(cmd, vg);
+		if (r != ECMD_PROCESSED)
+			return r;
+	}
 
-	else if (arg_count(cmd, monitor_ARG))
+	if (!arg_count(cmd, available_ARG) &&
+	    !arg_count(cmd, refresh_ARG) &&
+	    arg_count(cmd, monitor_ARG)) {
+		/* -ay* will have already done monitoring changes */
 		r = _vgchange_monitoring(cmd, vg);
+		if (r != ECMD_PROCESSED)
+			return r;
+	}
 
-	else if (arg_count(cmd, poll_ARG))
+	if (!arg_count(cmd, refresh_ARG) &&
+	    arg_count(cmd, poll_ARG))
 		r = _vgchange_background_polling(cmd, vg);
 
 	else if (arg_count(cmd, resizeable_ARG))
@@ -628,9 +646,6 @@
 	else if (arg_count(cmd, clustered_ARG))
 		r = _vgchange_clustered(cmd, vg);
 
-	else if (arg_count(cmd, refresh_ARG))
-		r = _vgchange_refresh(cmd, vg);
-
 	else if (arg_count(cmd, vgmetadatacopies_ARG) ||
 		 arg_count(cmd, metadatacopies_ARG))
 		r = _vgchange_metadata_copies(cmd, vg);
@@ -669,12 +684,26 @@
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, available_ARG) && arg_count(cmd, refresh_ARG)) {
+		log_error("Only one of -a and --refresh permitted.");
+		return EINVALID_CMD_LINE;
+	}
+
 	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
 	     arg_count(cmd, sysinit_ARG)) && !arg_count(cmd, available_ARG)) {
 		log_error("Only -a permitted with --ignorelockingfailure and --sysinit");
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, available_ARG) &&
+	    (arg_count(cmd, monitor_ARG) || arg_count(cmd, poll_ARG))) {
+		int activate = arg_uint_value(cmd, available_ARG, 0);
+		if (activate == CHANGE_AN || activate == CHANGE_ALN) {
+			log_error("Only -ay* allowed with --monitor or --poll.");
+			return EINVALID_CMD_LINE;
+		}
+	}
+
 	if (arg_count(cmd, poll_ARG) && arg_count(cmd, sysinit_ARG)) {
 		log_error("Only one of --poll and --sysinit permitted.");
 		return EINVALID_CMD_LINE;


