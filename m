From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 22 Jan 2010 21:59:43 -0000
Subject: LVM2 ./WHATS_NEW test/t-mirror-names.sh tools/ ...
Message-ID: <20100122215943.2978.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-22 21:59:43

Modified files:
	.              : WHATS_NEW 
	test           : t-mirror-names.sh 
	tools          : polldaemon.c polldaemon.h 

Log message:
	Default to checking LV's progress before waiting in _wait_for_single_lv.
	
	Support "wait before testing" using '+' in pvmove and lvconvert
	interval.  Doing so overrides the new default of sleeping after checking
	the LV's progress.
	
	Sleeping before checking progress can lead to extraneous polldaemons
	being left running.  These polldaemons would have otherwise exited had
	they checked before sleeping.  Checking progress before sleeping helps
	workaround the subtly unreliable nature of "finished" state checking
	in _percent_run.
	
	Update test/t-mirror-names.sh to use '+' when providing its lvconvert
	interval.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1405&r2=1.1406
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-names.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2010/01/22 16:19:38	1.1405
+++ LVM2/WHATS_NEW	2010/01/22 21:59:42	1.1406
@@ -1,5 +1,7 @@
 Version 2.02.60
 ===================================
+  Support "wait before testing" using '+' in pvmove and lvconvert interval.
+  Default to checking LV's progress before waiting in _wait_for_single_lv.
   Fix syntax error in cmirror init script.
   Eliminate extra ioctls just to check open_count in _add_new_lv_to_dtree.
   Disable not thread-safe memory debugging if dmeventd is configured.
--- LVM2/test/t-mirror-names.sh	2008/11/10 12:41:52	1.4
+++ LVM2/test/t-mirror-names.sh	2010/01/22 21:59:42	1.5
@@ -122,7 +122,7 @@
 
 #COMM "converting mirror names is ${lv1}_mimagetmp_2"
 lvcreate -l2 -m1 -n $lv1 $vg 
-lvconvert -m+1 -i1000 -b $vg/$lv1 
+lvconvert -m+1 -i+1000 -b $vg/$lv1
 convlv=$(lv_convert_lv_ "$vg/$lv1") 
 test "$convlv" = "$lv1"_mimagetmp_2 
 lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 
--- LVM2/tools/polldaemon.c	2010/01/11 19:19:17	1.31
+++ LVM2/tools/polldaemon.c	2010/01/22 21:59:43	1.32
@@ -156,8 +156,18 @@
 	return 1;
 }
 
+static void _sleep_and_rescan_devices(struct daemon_parms *parms)
+{
+	/* FIXME Use alarm for regular intervals instead */
+	if (parms->interval && !parms->aborting) {
+		sleep(parms->interval);
+		/* Devices might have changed while we slept */
+		init_full_scan_done(0);
+	}
+}
+
 static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const char *uuid,
-				   struct daemon_parms *parms)
+			       struct daemon_parms *parms)
 {
 	struct volume_group *vg;
 	struct logical_volume *lv;
@@ -165,13 +175,8 @@
 
 	/* Poll for completion */
 	while (!finished) {
-		/* FIXME Also needed in vg/lvchange -ay? */
-		/* FIXME Use alarm for regular intervals instead */
-		if (parms->interval && !parms->aborting) {
-			sleep(parms->interval);
-			/* Devices might have changed while we slept */
-			init_full_scan_done(0);
-		}
+		if (parms->wait_before_testing)
+			_sleep_and_rescan_devices(parms);
 
 		/* Locks the (possibly renamed) VG again */
 		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid);
@@ -196,6 +201,21 @@
 		}
 
 		unlock_and_release_vg(cmd, vg, vg->name);
+
+		/*
+		 * FIXME Sleeping after testing, while preferred, also works around
+		 * unreliable "finished" state checking in _percent_run.  If the
+		 * above _check_lv_status is deferred until after the first sleep it
+		 * may be that a polldaemon will run without ever completing.
+		 *
+		 * This happens when one snapshot-merge polldaemon is racing with
+		 * another (polling the same LV).  The first to see the LV status
+		 * reach the "finished" state will alter the LV that the other
+		 * polldaemon(s) are polling.  These other polldaemon(s) can then
+		 * continue polling an LV that doesn't have a "status".
+		 */
+		if (!parms->wait_before_testing)
+			_sleep_and_rescan_devices(parms);
 	}
 
 	return 1;
@@ -253,17 +273,23 @@
 	struct daemon_parms parms;
 	int daemon_mode = 0;
 	int ret = ECMD_PROCESSED;
+	sign_t interval_sign;
 
 	parms.aborting = arg_is_set(cmd, abort_ARG);
 	parms.background = background;
+	interval_sign = arg_sign_value(cmd, interval_ARG, 0);
+	if (interval_sign == SIGN_MINUS)
+		log_error("Argument to --interval cannot be negative");
 	parms.interval = arg_uint_value(cmd, interval_ARG, DEFAULT_INTERVAL);
+	parms.wait_before_testing = (interval_sign == SIGN_PLUS);
 	parms.progress_display = 1;
 	parms.progress_title = progress_title;
 	parms.lv_type = lv_type;
 	parms.poll_fns = poll_fns;
 
 	if (parms.interval && !parms.aborting)
-		log_verbose("Checking progress every %u seconds",
+		log_verbose("Checking progress %s waiting every %u seconds",
+			    (parms.wait_before_testing ? "after" : "before"),
 			    parms.interval);
 
 	if (!parms.interval) {
--- LVM2/tools/polldaemon.h	2009/09/30 18:15:06	1.10
+++ LVM2/tools/polldaemon.h	2010/01/22 21:59:43	1.11
@@ -53,6 +53,7 @@
 
 struct daemon_parms {
 	unsigned interval;
+	unsigned wait_before_testing;
 	unsigned aborting;
 	unsigned background;
 	unsigned outstanding_count;


