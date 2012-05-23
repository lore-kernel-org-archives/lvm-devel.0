From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 May 2012 13:02:37 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20120523130237.506.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-05-23 13:02:37

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Fix error path
	
	Do not increase nr_filt in case of NULL ret value, since the error path
	doesn't handle NULL pointers.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2408&r2=1.2409
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157

--- LVM2/WHATS_NEW	2012/05/16 13:09:09	1.2408
+++ LVM2/WHATS_NEW	2012/05/23 13:02:36	1.2409
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix error paths for regex filter initialization.
   Re-enable partial activation of non-thin LVs until it can be fixed. (2.02.90)
   Fix alloc cling to cling to PVs already found with contiguous policy.
   Fix cling policy not to behave like normal policy if no previous LV seg.
--- LVM2/lib/commands/toolcontext.c	2012/03/23 09:42:36	1.156
+++ LVM2/lib/commands/toolcontext.c	2012/05/23 13:02:37	1.157
@@ -759,17 +759,19 @@
 		log_very_verbose("devices/filter not found in config file: "
 				 "no regex filter installed");
 
-	else if (!(filters[nr_filt++] = regex_filter_create(cn->v))) {
+	else if (!(filters[nr_filt] = regex_filter_create(cn->v))) {
 		log_error("Failed to create regex device filter");
 		goto bad;
-	}
+	} else
+		nr_filt++;
 
 	/* device type filter. Required. */
 	cn = find_config_tree_node(cmd, "devices/types");
-	if (!(filters[nr_filt++] = lvm_type_filter_create(cmd->proc_dir, cn))) {
+	if (!(filters[nr_filt] = lvm_type_filter_create(cmd->proc_dir, cn))) {
 		log_error("Failed to create lvm type filter");
 		goto bad;
 	}
+	nr_filt++;
 
 	/* md component filter. Optional, non-critical. */
 	if (find_config_tree_bool(cmd, "devices/md_component_detection",


