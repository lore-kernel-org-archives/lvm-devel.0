From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Aug 2011 17:56:12 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-file.c
Message-ID: <20110804175612.8219.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-04 17:56:12

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-file.c 

Log message:
	Add missing check for allocation failure
	
	Static analyzer discovered missing check.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.485&r2=1.486
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-file.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW_DM	2011/07/28 13:06:50	1.485
+++ LVM2/WHATS_NEW_DM	2011/08/04 17:56:11	1.486
@@ -1,5 +1,6 @@
 Version 1.02.66 - 
 ===============================
+  Add missing check for allocation failure _create_dir_recursive().
   Add support for systemd file descriptor handover in dmeventd.
   Add support for new oom killer adjustment interface (oom_score_adj).
   Add systemd unit files for dmeventd.
--- LVM2/libdm/libdm-file.c	2011/04/08 14:40:20	1.15
+++ LVM2/libdm/libdm-file.c	2011/08/04 17:56:12	1.16
@@ -27,6 +27,11 @@
 	log_verbose("Creating directory \"%s\"", dir);
 	/* Create parent directories */
 	orig = s = dm_strdup(dir);
+	if (!s) {
+		log_error("Failed to duplicate directory name.");
+		return 0;
+	}
+
 	while ((s = strchr(s, '/')) != NULL) {
 		*s = '\0';
 		if (*orig) {


