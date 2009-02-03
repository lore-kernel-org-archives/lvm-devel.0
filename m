From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 3 Feb 2009 16:19:27 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20090203161927.12950.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-02-03 16:19:26

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : toollib.c 

Log message:
	Rename get_vgs() to get_vgnames() and clarify related error messages.
	
	get_vgs() really returns a list of vgnames.  In the future we will use
	get_vgs() to return a list of vg structures, similar to get_pvs().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1032&r2=1.1033
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.202&r2=1.203
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142

--- LVM2/WHATS_NEW	2009/02/02 14:34:24	1.1032
+++ LVM2/WHATS_NEW	2009/02/03 16:19:25	1.1033
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Rename get_vgs() to get_vgnames() and clarify related error messages.
   Allow clvmd to be built with all cluster managers & select one on cmdline.
   Mention --with-clvmd=corosync in ./configure.
   Replace internal vg_check_status() implementation.
--- LVM2/lib/metadata/metadata-exported.h	2009/01/27 01:48:47	1.60
+++ LVM2/lib/metadata/metadata-exported.h	2009/02/03 16:19:26	1.61
@@ -370,7 +370,7 @@
 struct dm_list *get_pvs(struct cmd_context *cmd);
 
 /* Set full_scan to 1 to re-read every (filtered) device label */
-struct dm_list *get_vgs(struct cmd_context *cmd, int full_scan);
+struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan);
 struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan);
 int scan_vgs_for_pvs(struct cmd_context *cmd);
 
--- LVM2/lib/metadata/metadata.c	2009/01/27 01:48:47	1.202
+++ LVM2/lib/metadata/metadata.c	2009/02/03 16:19:26	1.203
@@ -2039,8 +2039,8 @@
 	 *       allowed to do a full scan here any more. */
 
 	// The slow way - full scan required to cope with vgrename
-	if (!(vgnames = get_vgs(cmd, 2))) {
-		log_error("vg_read_by_vgid: get_vgs failed");
+	if (!(vgnames = get_vgnames(cmd, 2))) {
+		log_error("vg_read_by_vgid: get_vgnames failed");
 		return NULL;
 	}
 
@@ -2167,7 +2167,7 @@
 }
 
 /* May return empty list */
-struct dm_list *get_vgs(struct cmd_context *cmd, int full_scan)
+struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan)
 {
 	return lvmcache_get_vgnames(cmd, full_scan);
 }
@@ -2201,7 +2201,7 @@
 
 	/* Get list of VGs */
 	if (!(vgids = get_vgids(cmd, 0))) {
-		log_error("get_pvs: get_vgs failed");
+		log_error("get_pvs: get_vgids failed");
 		return 0;
 	}
 
--- LVM2/tools/toollib.c	2009/01/26 19:01:32	1.141
+++ LVM2/tools/toollib.c	2009/02/03 16:19:26	1.142
@@ -273,7 +273,7 @@
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all logical volumes");
-		if (!(vgnames = get_vgs(cmd, 0)) || dm_list_empty(vgnames)) {
+		if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames)) {
 			log_error("No volume groups found");
 			return ret_max;
 		}
@@ -713,7 +713,7 @@
 			if (sigint_caught())
 				return ret_max;
 		}
-		if (!dm_list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
+		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 0)) &&
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
 				if (!lock_vol(cmd, sll->str, lock_type)) {


