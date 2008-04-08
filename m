From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Apr 2008 21:38:09 -0000
Subject: LVM2 ./WHATS_NEW tools/vgsplit.c
Message-ID: <20080408213809.13010.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-08 21:38:09

Modified files:
	.              : WHATS_NEW 
	tools          : vgsplit.c 

Log message:
	Fix vgsplit error paths to release vg_to lock.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.832&r2=1.833
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/WHATS_NEW	2008/04/08 14:22:12	1.832
+++ LVM2/WHATS_NEW	2008/04/08 21:38:08	1.833
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix vgsplit error paths to release vg_to lock.
   Indicate whether or not VG is clustered in vgcreate log message.
   Mention default --clustered setting in vgcreate man page.
   Add config file overrides to clvmd when it reads the active LVs list.
--- LVM2/tools/vgsplit.c	2008/04/02 19:30:12	1.54
+++ LVM2/tools/vgsplit.c	2008/04/08 21:38:09	1.55
@@ -288,11 +288,13 @@
 
 		if (fill_vg_create_params(cmd, vg_name_to, &vp_new, &vp_def)) {
 			unlock_vg(cmd, vg_name_from);
+			unlock_vg(cmd, vg_name_to);
 			return EINVALID_CMD_LINE;
 		}
 
 		if (validate_vg_create_params(cmd, &vp_new)) {
 			unlock_vg(cmd, vg_name_from);
+			unlock_vg(cmd, vg_name_to);
 			return EINVALID_CMD_LINE;
 		}
 


