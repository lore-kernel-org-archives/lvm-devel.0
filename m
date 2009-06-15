From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jun 2009 14:47:40 -0000
Subject: LVM2 daemons/dmeventd/plugins/mirror/dmeventd_ ...
Message-ID: <20090615144740.4472.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-06-15 14:47:40

Modified files:
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	tools          : lvconvert.c vgreduce.c 

Log message:
	- Ignore suspended devices during repair (Milan).
	- Call vgreduce --removemissing (without --force) automatically to clean up bad
	PVs (Milan).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/06/04 12:01:15	1.23
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/06/15 14:47:39	1.24
@@ -161,6 +161,12 @@
 
 	r = lvm2_run(_lvm_handle, cmd_str);
 
+	if (r == 1) {
+		snprintf(cmd_str, CMD_SIZE, "vgreduce --removemissing %s", vg);
+		if (lvm2_run(_lvm_handle, cmd_str) != 1)
+			syslog(LOG_ERR, "Unable to remove failed PVs from VG %s", vg);
+	}
+
 	dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
 	return (r == 1) ? 0 : -1;
 }
--- LVM2/tools/lvconvert.c	2009/06/15 13:43:16	1.81
+++ LVM2/tools/lvconvert.c	2009/06/15 14:47:39	1.82
@@ -926,18 +926,22 @@
 	struct lvconvert_params lp;
 	int ret = ECMD_FAILED;
 	struct lvinfo info;
+	int saved_ignore_suspended_devices = ignore_suspended_devices();
 
 	if (!_read_params(&lp, cmd, argc, argv)) {
 		stack;
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, repair_ARG))
+		init_ignore_suspended_devices(1);
+
 	log_verbose("Checking for existing volume group \"%s\"", lp.vg_name);
 
 	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
 				    CORRECT_INCONSISTENT)))
-		return ECMD_FAILED;
+		goto out;
 
 	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
 		log_error("Logical volume \"%s\" not found in "
@@ -966,6 +970,7 @@
 				     lp.wait_completion ? 0 : 1U);
 	}
 out:
+	init_ignore_suspended_devices(saved_ignore_suspended_devices);
 	vg_release(vg);
 	return ret;
 }
--- LVM2/tools/vgreduce.c	2009/05/21 03:04:54	1.91
+++ LVM2/tools/vgreduce.c	2009/06/15 14:47:40	1.92
@@ -466,6 +466,7 @@
 	int consistent = 1;
 	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
+	int saved_ignore_suspended_devices = ignore_suspended_devices();
 
 	if (!argc && !repairing) {
 		log_error("Please give volume group name and "
@@ -515,6 +516,9 @@
 		return ECMD_FAILED;
 	}
 
+	if (repairing)
+		init_ignore_suspended_devices(1);
+
 	if ((!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent)) || !consistent)
 	    && !repairing) {
 		log_error("Volume group \"%s\" doesn't exist", vg_name);
@@ -574,6 +578,7 @@
 
 	}
 out:
+	init_ignore_suspended_devices(saved_ignore_suspended_devices);
 	unlock_and_release_vg(cmd, vg, vg_name);
 
 	return ret;


