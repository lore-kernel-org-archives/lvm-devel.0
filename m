From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Dec 2006 16:19:02 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20061220161902.14253.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-12-20 16:19:01

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Fix some activate.c prototypes when compiled without devmapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.524&r2=1.525
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/WHATS_NEW	2006/12/20 14:34:04	1.524
+++ LVM2/WHATS_NEW	2006/12/20 16:19:01	1.525
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Fix some activate.c prototypes when compiled without devmapper.
   Fix dmeventd mirror to cope if monitored device disappears.
 
 Version 2.02.17 - 14th December 2006
--- LVM2/lib/activate/activate.c	2006/10/03 17:55:19	1.114
+++ LVM2/lib/activate/activate.c	2006/12/20 16:19:01	1.115
@@ -141,7 +141,7 @@
 {
 	return 0;
 }
-int target_present(const char *target_name)
+int target_present(const char *target_name, int use_modprobe)
 {
 	return 0;
 }
@@ -211,7 +211,7 @@
 	return 1;
 }
 
-int pv_uses_vg(struct cmd_context *cmd, struct physical_volume *pv,
+int pv_uses_vg(struct physical_volume *pv,
 	       struct volume_group *vg)
 {
 	return 0;


