From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 4 Jun 2009 12:01:18 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/mirr ...
Message-ID: <20090604120118.4645.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-04 12:01:16

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	doc            : example.conf 
	lib/config     : defaults.h 
	man            : lvconvert.8.in 
	test           : t-lvconvert-repair.sh 
	tools          : args.h commands.h lvconvert.c 

Log message:
	Use lvconvert --repair instead of vgreduce in mirror dmeventd DSO (mornfall)
	Introduce lvconvert --use_policies (mornfall)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1140&r2=1.1141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/WHATS_NEW	2009/06/03 13:42:02	1.1140
+++ LVM2/WHATS_NEW	2009/06/04 12:01:15	1.1141
@@ -1,5 +1,7 @@
 Version 2.02.48 - 
 ===============================
+  Use lvconvert --repair instead of vgreduce in mirror dmeventd DSO.
+  Introduce lvconvert --use_policies (repair policy according to lvm.conf).
   Fix clvmd-corosync to match new corosync API.
   Fix makefile to build also shared libraries when running plain make.
   Fix rename of active snapshot with virtual origin.
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/05/20 22:24:49	1.22
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/06/04 12:01:15	1.23
@@ -152,7 +152,7 @@
 	}
 
 	/* FIXME Is any sanity-checking required on %s? */
-	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "vgreduce --config devices{ignore_suspended_devices=1} --removemissing --force %s", vg)) {
+	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies %s/%s", vg, lv)) {
 		/* this error should be caught above, but doesn't hurt to check again */
 		syslog(LOG_ERR, "Unable to form LVM command: Device name too long");
 		dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
--- LVM2/doc/example.conf	2009/02/22 19:00:26	1.39
+++ LVM2/doc/example.conf	2009/06/04 12:01:15	1.40
@@ -317,8 +317,10 @@
     # A disk log ensures that a mirror does not need to be re-synced
     # (all copies made the same) every time a machine reboots or crashes.
     #
-    # In the event of a failure, the specified policy will be used to
-    # determine what happens:
+    # In the event of a failure, the specified policy will be used to determine
+    # what happens. This applies to automatic repairs (when the mirror is being
+    # monitored by dmeventd) and to manual lvconvert --repair when
+    # --use-policies is given.
     #
     # "remove" - Simply remove the faulty device and run without it.  If
     #            the log device fails, the mirror would convert to using
@@ -338,20 +340,13 @@
     #            will preserve the mirror characteristic of the device.
     #            This policy acts like "remove" if no suitable device and
     #            space can be allocated for the replacement.
-    #            Currently this is not implemented properly and behaves
-    #            similarly to:
     #
-    # "allocate_anywhere" - Operates like "allocate", but it does not
-    #            require that the new space being allocated be on a
-    #            device is not part of the mirror.  For a log device
-    #            failure, this could mean that the log is allocated on
-    #            the same device as a mirror device.  For a mirror
-    #            device, this could mean that the mirror device is
-    #            allocated on the same device as another mirror device.
-    #            This policy would not be wise for mirror devices
-    #            because it would break the redundant nature of the
-    #            mirror.  This policy acts like "remove" if no suitable
-    #            device and space can be allocated for the replacement.
+    # "allocate_anywhere" - Not yet implemented. Useful to place the log device
+    #            temporarily on same physical volume as one of the mirror
+    #            images. This policy is not recommended for mirror devices
+    #            since it would break the redundant nature of the mirror. This
+    #            policy acts like "remove" if no suitable device and space can
+    #            be allocated for the replacement.
 
     mirror_log_fault_policy = "allocate"
     mirror_device_fault_policy = "remove"
--- LVM2/lib/config/defaults.h	2008/09/19 06:41:58	1.44
+++ LVM2/lib/config/defaults.h	2009/06/04 12:01:15	1.45
@@ -126,4 +126,7 @@
 #define DEFAULT_SEGS_SORT "vg_name,lv_name,seg_start"
 #define DEFAULT_PVSEGS_SORT "pv_name,pvseg_start"
 
+#define DEFAULT_MIRROR_DEVICE_FAULT_POLICY "remove"
+#define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
+
 #endif				/* _LVM_DEFAULTS_H */
--- LVM2/man/lvconvert.8.in	2009/04/23 16:56:22	1.3
+++ LVM2/man/lvconvert.8.in	2009/06/04 12:01:15	1.4
@@ -63,8 +63,14 @@
 .TP
 .I \-\-repair
 Repair a mirror that has suffered a disk failure. The mirror will be brought
-back into a consistent state, and if possible, the original number of
-mirrors will be restored.
+back into a consistent state, and if possible, the original number of mirrors
+will be restored, if so desired. By default, lvconvert will prompt you whether
+to perform the replacement. If you instead wish to unconditionally replace
+missing devices, you may specify \-y on the commandline and if you instead want
+no replacement to happen@all, you may provide \-f. Additionally, you may use
+"--use-policies" - this option will use the device replacement policy specified
+in lvm.conf, specifically "activation/mirror_log_fault_policy" and
+"activation/mirror_device_fault_policy".
 .br
 .TP
 .I \-s, \-\-snapshot
--- LVM2/test/t-lvconvert-repair.sh	2009/04/23 16:56:21	1.1
+++ LVM2/test/t-lvconvert-repair.sh	2009/06/04 12:01:16	1.2
@@ -22,19 +22,19 @@
 lvchange --partial -a y $vg/mirror
 
 not vgreduce -v --removemissing $vg
-lvconvert -i 1 --repair $vg/mirror
+lvconvert -y -i 1 --repair $vg/mirror
 vgreduce --removemissing $vg
 
 enable_dev $dev1
 vgextend $vg $dev1
 disable_dev $dev2
-lvconvert -i 1 --repair $vg/mirror
+lvconvert -y -i 1 --repair $vg/mirror
 vgreduce --removemissing $vg
 
 enable_dev $dev2
 vgextend $vg $dev2
 disable_dev $dev3
-lvconvert -i 1 --repair $vg/mirror
+lvconvert -y -i 1 --repair $vg/mirror
 vgreduce --removemissing $vg
 
 enable_dev $dev3
@@ -42,5 +42,5 @@
 lvcreate -m 2 -l 1 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4
 vgchange -a n $vg
 pvremove -ff -y $dev4
-echo 'y' | not lvconvert -i 1 --repair $vg/mirror2
+echo 'y' | not lvconvert -y -i 1 --repair $vg/mirror2
 vgs
--- LVM2/tools/args.h	2009/05/27 16:30:30	1.64
+++ LVM2/tools/args.h	2009/06/04 12:01:16	1.65
@@ -50,6 +50,7 @@
 arg(corelog_ARG, '\0', "corelog", NULL, 0)
 arg(mirrorlog_ARG, '\0', "mirrorlog", string_arg, 0)
 arg(repair_ARG, '\0', "repair", NULL, 0)
+arg(use_policies_ARG, '\0', "use-policies", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
 arg(config_ARG, '\0', "config", string_arg, 0)
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
--- LVM2/tools/commands.h	2009/05/27 16:30:30	1.126
+++ LVM2/tools/commands.h	2009/06/04 12:01:16	1.127
@@ -94,7 +94,7 @@
    0,
    "lvconvert "
    "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
-   "\t[--repair]\n"
+   "\t[--repair [--use-policies]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
@@ -117,7 +117,7 @@
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
    mirrorlog_ARG, mirrors_ARG, regionsize_ARG, repair_ARG, snapshot_ARG,
-   test_ARG, zero_ARG)
+   test_ARG, use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
--- LVM2/tools/lvconvert.c	2009/06/01 14:43:28	1.77
+++ LVM2/tools/lvconvert.c	2009/06/04 12:01:16	1.78
@@ -457,6 +457,49 @@
 	return next_lv;
 }
 
+static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
+					  int failed_log, int failed_mirrors,
+					  int *replace_log, int *replace_mirrors)
+{
+	const char *leg_policy = NULL, *log_policy = NULL;
+
+	int force = arg_count(cmd, force_ARG);
+	int yes = arg_count(cmd, yes_ARG);
+
+	*replace_log = *replace_mirrors = 1;
+
+	if (arg_count(cmd, use_policies_ARG)) {
+		leg_policy = find_config_tree_str(cmd,
+					"activation/mirror_device_fault_policy",
+					DEFAULT_MIRROR_DEVICE_FAULT_POLICY);
+		log_policy = find_config_tree_str(cmd,
+					"activation/mirror_log_fault_policy",
+					DEFAULT_MIRROR_LOG_FAULT_POLICY);
+		*replace_mirrors = strcmp(leg_policy, "remove");
+		*replace_log = strcmp(log_policy, "remove");
+		return;
+	}
+
+	if (yes)
+		return;
+
+	if (force != PROMPT) {
+		*replace_log = *replace_mirrors = 0;
+		return;
+	}
+
+	if (failed_log &&
+	    yes_no_prompt("Attempt to replace failed mirror log? [y/n]: ") == 'n') {
+		*replace_log = 0;
+	}
+
+	if (failed_mirrors &&
+	    yes_no_prompt("Attempt to replace failed mirror images "
+			  "(requires full device resync)? [y/n]: ") == 'n') {
+		*replace_mirrors = 0;
+	}
+}
+
 static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
@@ -470,18 +513,21 @@
 	int failed_mirrors = 0, failed_log = 0;
 	struct dm_list *old_pvh = NULL, *remove_pvs = NULL;
 
+	int repair = arg_count(cmd, repair_ARG);
+	int replace_log = 1, replace_mirrors = 1;
+
 	seg = first_seg(lv);
 	existing_mirrors = lv_mirror_count(lv);
 
 	/* If called with no argument, try collapsing the resync layers */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
 	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG) &&
-	    !arg_count(cmd, repair_ARG)) {
+	    !repair) {
 		lp->need_polling = 1;
 		return 1;
 	}
 
-	if (arg_count(cmd, mirrors_ARG) && arg_count(cmd, repair_ARG)) {
+	if (arg_count(cmd, mirrors_ARG) && repair) {
 		log_error("You can only use one of -m, --repair.");
 		return 0;
 	}
@@ -503,7 +549,7 @@
 	else
 		lp->mirrors += 1;
 
-	if (arg_count(cmd,repair_ARG)) {
+	if (repair) {
 		cmd->handles_missing_pvs = 1;
 		cmd->partial_activation = 1;
 		lp->need_polling = 0;
@@ -514,7 +560,7 @@
 		if ((failed_mirrors = _failed_mirrors_count(lv)) < 0)
 			return_0;
 		lp->mirrors -= failed_mirrors;
-		log_error("Mirror status: %d/%d legs failed.",
+		log_error("Mirror status: %d/%d images failed.",
 			  failed_mirrors, existing_mirrors);
 		old_pvh = lp->pvh;
 		if (!(lp->pvh = _failed_pv_list(lv->vg)))
@@ -577,6 +623,10 @@
 		return 0;
 	}
 
+	if (repair)
+		_lvconvert_mirrors_repair_ask(cmd, failed_log, failed_mirrors,
+					      &replace_log, &replace_mirrors);
+
  restart:
 	/*
 	 * Converting from mirror to linear
@@ -594,7 +644,7 @@
 	 */
 	if (lp->mirrors < existing_mirrors) {
 		/* Reduce number of mirrors */
-		if (arg_count(cmd, repair_ARG) || lp->pv_count)
+		if (repair || lp->pv_count)
 			remove_pvs = lp->pvh;
 		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
 				       (corelog || lp->mirrors == 1) ? 1U : 0U,
@@ -727,13 +777,15 @@
 
 	if (failed_log || failed_mirrors) {
 		lp->pvh = old_pvh;
-		if (failed_log)
+		if (failed_log && replace_log)
 			failed_log = corelog = 0;
-		lp->mirrors += failed_mirrors;
+		if (replace_mirrors)
+			lp->mirrors += failed_mirrors;
 		failed_mirrors = 0;
 		existing_mirrors = lv_mirror_count(lv);
 		/* Now replace missing devices. */
-		goto restart;
+		if (replace_log || replace_mirrors)
+			goto restart;
 	}
 
 	if (!lp->need_polling)


