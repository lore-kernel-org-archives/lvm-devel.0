From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 29 Mar 2010 16:09:43 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c tools/lvcrea ...
Message-ID: <20100329160943.5232.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-03-29 16:09:41

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c lvcreate.c toollib.c toollib.h 
	                 vgchange.c 

Log message:
	Do not allow {vg|lv}change --ignoremonitoring if on clustered VG.
	
	clvmd does not propagate DMEVENTD_MONITOR_IGNORE.
	
	Update get_activation_monitoring_mode() to check if the VG that the
	LV is being activated in is clustered.  If so, skip it.
	
	Any get_activation_monitoring_mode() error will cause the associated LV
	(or VG) to be skipped during activation.  Both vgchange_single() and
	lvchange_single(), which call get_activation_monitoring_mode(), are
	called by their respective process_each_..() method.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1486&r2=1.1487
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.217&r2=1.218
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.190&r2=1.191
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/WHATS_NEW	2010/03/29 14:17:59	1.1486
+++ LVM2/WHATS_NEW	2010/03/29 16:09:40	1.1487
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Do not allow {vg|lv}change --ignoremonitoring if on clustered VG.
   Improved dependency tracking for dmeventd and liblvm2cmd sources.
   Improved Makefile rules for distclean and cflow targets.
   Add ability to create mirrored logs for mirror LVs.
--- LVM2/tools/lvchange.c	2010/03/23 22:30:20	1.118
+++ LVM2/tools/lvchange.c	2010/03/29 16:09:41	1.119
@@ -575,7 +575,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!get_activation_monitoring_mode(cmd, &dmeventd_mode))
+	if (!get_activation_monitoring_mode(cmd, lv->vg, &dmeventd_mode))
 		return ECMD_FAILED;
 
 	init_dmeventd_monitor(dmeventd_mode);
--- LVM2/tools/lvcreate.c	2010/03/26 22:15:44	1.217
+++ LVM2/tools/lvcreate.c	2010/03/29 16:09:41	1.218
@@ -484,7 +484,8 @@
 		return 0;
 	}
 
-	if (!get_activation_monitoring_mode(cmd, &lp->activation_monitoring))
+	if (!get_activation_monitoring_mode(cmd, NULL,
+					    &lp->activation_monitoring))
 		return_0;
 
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
--- LVM2/tools/toollib.c	2010/03/23 22:30:20	1.190
+++ LVM2/tools/toollib.c	2010/03/29 16:09:41	1.191
@@ -1424,6 +1424,7 @@
 }
 
 int get_activation_monitoring_mode(struct cmd_context *cmd,
+				   struct volume_group *vg,
 				   int *monitoring_mode)
 {
 	*monitoring_mode = DEFAULT_DMEVENTD_MONITOR;
@@ -1441,6 +1442,16 @@
 		 !find_config_tree_bool(cmd, "activation/monitoring",
 					DEFAULT_DMEVENTD_MONITOR))
 		*monitoring_mode = DMEVENTD_MONITOR_IGNORE;
+
+	if (vg && vg_is_clustered(vg) &&
+	    *monitoring_mode == DMEVENTD_MONITOR_IGNORE) {
+		log_error("%s is incompatible with clustered Volume Group "
+			  "\"%s\": Skipping.",
+			  (arg_count(cmd, ignoremonitoring_ARG) ?
+			   "--ignoremonitoring" : "activation/monitoring=0"),
+			  vg->name);
+		return 0;
+	}
 	
 	return 1;
 }
--- LVM2/tools/toollib.h	2010/03/23 22:30:20	1.70
+++ LVM2/tools/toollib.h	2010/03/29 16:09:41	1.71
@@ -113,6 +113,7 @@
 			     struct pvcreate_params *pp);
 
 int get_activation_monitoring_mode(struct cmd_context *cmd,
+				   struct volume_group *vg,
 				   int *monitoring_mode);
 
 #endif
--- LVM2/tools/vgchange.c	2010/03/23 22:30:20	1.100
+++ LVM2/tools/vgchange.c	2010/03/29 16:09:41	1.101
@@ -529,7 +529,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!get_activation_monitoring_mode(cmd, &dmeventd_mode))
+	if (!get_activation_monitoring_mode(cmd, vg, &dmeventd_mode))
 		return ECMD_FAILED;
 
 	init_dmeventd_monitor(dmeventd_mode);


