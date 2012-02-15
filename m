From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Feb 2012 15:18:46 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20120215151846.17172.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-15 15:18:44

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata-exported.h 
	liblvm         : lvm_lv.c 
	tools          : lvchange.c lvcreate.c lvmcmdline.c toollib.c 
	                 toollib.h vgchange.c 

Log message:
	Initialize dmeventd monitoring for every command
	
	Read lvm.conf setting for monitoring for each command. So we should not
	activate monitoring if the default compilation is set to monitor during
	lvconvert commnads.
	
	Patch also removes check for  clustered VG and allows to disable monitoring
	for clustered VG with the assumption, the problem with monitoring and dmeventd
	flag passing for INGNORE is already fixed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2294&r2=1.2295
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.361&r2=1.362
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.230&r2=1.231
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.253&r2=1.254
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.240&r2=1.241
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130

--- LVM2/WHATS_NEW	2012/02/15 13:49:51	1.2294
+++ LVM2/WHATS_NEW	2012/02/15 15:18:43	1.2295
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Read monitoring config settings for every lvm command.
   Initialize monitoring support only for thin pools and skip thin volumes.
   Make conversion from a synced 'mirror' to 'raid1' not cause a full resync.
   Properly test buffer for unit check in units_to_bytes().
--- LVM2/lib/metadata/lv_manip.c	2012/02/13 11:25:56	1.361
+++ LVM2/lib/metadata/lv_manip.c	2012/02/15 15:18:43	1.362
@@ -4378,8 +4378,6 @@
 		goto out;
 	}
 
-	init_dmeventd_monitor(lp->activation_monitoring);
-
 	if (seg_is_thin(lp)) {
 		/* For snapshot, suspend active thin origin first */
 		if (org && lv_is_active(org)) {
--- LVM2/lib/metadata/metadata-exported.h	2012/02/12 23:01:19	1.230
+++ LVM2/lib/metadata/metadata-exported.h	2012/02/15 15:18:43	1.231
@@ -574,7 +574,6 @@
 	int minor; /* all */
 	int log_count; /* mirror */
 	int nosync; /* mirror */
-	int activation_monitoring; /* all */
 	activation_change_t activate; /* non-snapshot, non-mirror */
 
 	const char *origin; /* snap */
--- LVM2/liblvm/lvm_lv.c	2012/02/13 11:25:56	1.38
+++ LVM2/liblvm/lvm_lv.c	2012/02/15 15:18:43	1.39
@@ -110,7 +110,6 @@
 	lp->zero = 1;
 	lp->major = -1;
 	lp->minor = -1;
-	lp->activation_monitoring = DEFAULT_DMEVENTD_MONITOR;
 	lp->activate = CHANGE_AY;
 	lp->vg_name = vg->name;
 	lp->lv_name = lvname; /* FIXME: check this for safety */
--- LVM2/tools/lvchange.c	2011/12/01 00:04:21	1.137
+++ LVM2/tools/lvchange.c	2012/02/15 15:18:44	1.138
@@ -524,7 +524,7 @@
 			   void *handle __attribute__((unused)))
 {
 	int doit = 0, docmds = 0;
-	int dmeventd_mode, archived = 0;
+	int archived = 0;
 	struct logical_volume *origin;
 	char snaps_msg[128];
 
@@ -595,11 +595,6 @@
 		return ECMD_FAILED;
 	}
 
-	if (!get_activation_monitoring_mode(cmd, lv->vg, &dmeventd_mode))
-		return ECMD_FAILED;
-
-	init_dmeventd_monitor(dmeventd_mode);
-
 	/*
 	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
 	 * If --poll is explicitly provided use it; otherwise polling
--- LVM2/tools/lvcreate.c	2012/02/01 01:54:20	1.253
+++ LVM2/tools/lvcreate.c	2012/02/15 15:18:44	1.254
@@ -726,10 +726,6 @@
 		return 0;
 	}
 
-	if (!get_activation_monitoring_mode(cmd, NULL,
-					    &lp->activation_monitoring))
-		return_0;
-
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
--- LVM2/tools/lvmcmdline.c	2012/02/13 12:07:51	1.150
+++ LVM2/tools/lvmcmdline.c	2012/02/15 15:18:44	1.151
@@ -935,6 +935,7 @@
 	init_test(cmd->current_settings.test);
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
+	init_dmeventd_monitor(DEFAULT_DMEVENTD_MONITOR);
 
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 	init_cmd_name(cmd->default_settings.cmd_name);
@@ -996,6 +997,7 @@
 {
 	int ret = 0;
 	int locking_type;
+	int monitoring;
 	struct dm_config_tree *old_cft;
 
 	init_error_message_produced(0);
@@ -1041,6 +1043,10 @@
 		goto_out;
 	_apply_settings(cmd);
 
+	if (!get_activation_monitoring_mode(cmd, &monitoring))
+		goto_out;
+	init_dmeventd_monitor(monitoring);
+
 	log_debug("Processing: %s", cmd->cmd_line);
 
 #ifdef O_DIRECT_SUPPORT
--- LVM2/tools/toollib.c	2012/02/10 01:28:28	1.240
+++ LVM2/tools/toollib.c	2012/02/15 15:18:44	1.241
@@ -1490,7 +1490,6 @@
 }
 
 int get_activation_monitoring_mode(struct cmd_context *cmd,
-				   struct volume_group *vg,
 				   int *monitoring_mode)
 {
 	*monitoring_mode = DEFAULT_DMEVENTD_MONITOR;
@@ -1511,16 +1510,6 @@
 					DEFAULT_DMEVENTD_MONITOR))
 		*monitoring_mode = DMEVENTD_MONITOR_IGNORE;
 
-	if (vg && vg_is_clustered(vg) &&
-	    *monitoring_mode == DMEVENTD_MONITOR_IGNORE) {
-		log_error("%s is incompatible with clustered Volume Group "
-			  "\"%s\": Skipping.",
-			  (arg_count(cmd, ignoremonitoring_ARG) ?
-			   "--ignoremonitoring" : "activation/monitoring=0"),
-			  vg->name);
-		return 0;
-	}
-	
 	return 1;
 }
 
--- LVM2/tools/toollib.h	2011/02/18 14:47:31	1.77
+++ LVM2/tools/toollib.h	2012/02/15 15:18:44	1.78
@@ -110,7 +110,6 @@
 			     struct pvcreate_params *pp);
 
 int get_activation_monitoring_mode(struct cmd_context *cmd,
-				   struct volume_group *vg,
 				   int *monitoring_mode);
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
--- LVM2/tools/vgchange.c	2011/11/07 10:58:13	1.129
+++ LVM2/tools/vgchange.c	2012/02/15 15:18:44	1.130
@@ -447,7 +447,6 @@
 			   struct volume_group *vg,
 			   void *handle __attribute__((unused)))
 {
-	int dmeventd_mode;
 	int archived = 0;
 	int i;
 
@@ -473,11 +472,6 @@
 		return ECMD_FAILED;
 	}
 
-	if (!get_activation_monitoring_mode(cmd, vg, &dmeventd_mode))
-		return ECMD_FAILED;
-
-	init_dmeventd_monitor(dmeventd_mode);
-
 	/*
 	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
 	 * If --poll is explicitly provided use it; otherwise polling


