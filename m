From: bmr@sourceware.org <bmr@sourceware.org>
Date: 25 Jun 2007 13:19:38 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmdiskscan.c
Message-ID: <20070625131938.20550.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	bmr at sourceware.org	2007-06-25 13:19:37

Modified files:
	.              : WHATS_NEW 
	tools          : lvmdiskscan.c 

Log message:
	Fix lvmdiskscan volume reporting when run in the lvm shell

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.640&r2=1.641
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmdiskscan.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2007/06/25 09:02:37	1.640
+++ LVM2/WHATS_NEW	2007/06/25 13:19:37	1.641
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Fix lvmdiskscan volume reporting when run in the lvm shell
   Fix missing lvm_shell symbol in lvm2cmd library. (2.02.23)
   Add vg_status function and clean up vg->status in tools directory.
   Add --ignoremonitoring to disable all dmeventd interaction.
--- LVM2/tools/lvmdiskscan.c	2007/04/23 18:21:01	1.17
+++ LVM2/tools/lvmdiskscan.c	2007/06/25 13:19:37	1.18
@@ -21,10 +21,10 @@
 
 #include "tools.h"
 
-int disks_found = 0;
-int parts_found = 0;
-int pv_disks_found = 0;
-int pv_parts_found = 0;
+int disks_found;
+int parts_found;
+int pv_disks_found;
+int pv_parts_found;
 int max_len;
 
 static int _get_max_dev_name_len(struct dev_filter *filter)
@@ -99,6 +99,12 @@
 	struct device *dev;
 	struct label *label;
 
+	/* initialise these here to avoid problems with the lvm shell */
+	disks_found = 0;
+	parts_found = 0;
+	pv_disks_found = 0;
+	pv_parts_found = 0;
+
 	if (arg_count(cmd, lvmpartition_ARG))
 		log_print("WARNING: only considering LVM devices");
 


