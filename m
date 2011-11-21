From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 21 Nov 2011 12:31:29 -0000
Subject: LVM2 daemons/dmeventd/plugins/snapshot/dmevent ...
Message-ID: <20111121123129.3883.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-11-21 12:31:24

Modified files:
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 
	test/shell     : lvextend-snapshot-dmeventd.sh 

Log message:
	Fix a bug in dmeventd snapshot monitoring code where the monitoring threshold
	would grow with subsequent snapshot extensions (RHBZ 754198).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvextend-snapshot-dmeventd.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2011/10/19 14:31:49	1.16
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2011/11/21 12:31:18	1.17
@@ -40,6 +40,11 @@
 	int max;
 };
 
+struct dso_state {
+	int percent_check;
+	int known_size;
+};
+
 /* FIXME possibly reconcile this with target_percent when we gain
    access to regular LVM library here. */
 static void _parse_snapshot_params(char *params, struct snap_status *status)
@@ -181,10 +186,11 @@
 	char *params;
 	struct snap_status status = { 0 };
 	const char *device = dm_task_get_name(dmt);
-	int percent, *percent_check = (int*)private;
+	int percent;
+	struct dso_state *state = *private;
 
 	/* No longer monitoring, waiting for remove */
-	if (!*percent_check)
+	if (!state->percent_check)
 		return;
 
 	dmeventd_lvm2_lock();
@@ -204,27 +210,35 @@
 		} /* else; too bad, but this is best-effort thing... */
 	}
 
+	/* Snapshot size had changed. Clear the threshold. */
+	if (state->known_size != status.max) {
+		state->percent_check = CHECK_MINIMUM;
+		state->known_size = status.max;
+	}
+
 	/*
 	 * If the snapshot has been invalidated or we failed to parse
 	 * the status string. Report the full status string to syslog.
 	 */
 	if (status.invalid || !status.max) {
 		syslog(LOG_ERR, "Snapshot %s changed state to: %s\n", device, params);
-		*percent_check = 0;
+		state->percent_check = 0;
 		goto out;
 	}
 
 	percent = 100 * status.used / status.max;
-	if (percent >= *percent_check) {
+	if (percent >= state->percent_check) {
 		/* Usage has raised more than CHECK_STEP since the last
 		   time. Run actions. */
-		*percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
+		state->percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
+
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
 			syslog(LOG_WARNING, "Snapshot %s is now %i%% full.\n", device, percent);
 		/* Try to extend the snapshot, in accord with user-set policies */
 		if (!_extend(device))
 			syslog(LOG_ERR, "Failed to extend snapshot %s.", device);
 	}
+
 out:
 	dmeventd_lvm2_unlock();
 }
@@ -235,10 +249,14 @@
 		    int minor __attribute__((unused)),
 		    void **private)
 {
-	int *percent_check = (int*)private;
+	struct dso_state **state = (struct dso_state **) private;
 	int r = dmeventd_lvm2_init();
 
-	*percent_check = CHECK_MINIMUM;
+	if (!(*state = dm_malloc(sizeof (struct dso_state))))
+		return 0;
+
+	(*state)->percent_check = CHECK_MINIMUM;
+	(*state)->known_size = 0;
 
 	syslog(LOG_INFO, "Monitoring snapshot %s\n", device);
 	return r;
@@ -248,10 +266,13 @@
 		      const char *uuid __attribute__((unused)),
 		      int major __attribute__((unused)),
 		      int minor __attribute__((unused)),
-		      void **unused __attribute__((unused)))
+		      void **private)
 {
+	struct dso_state *state = *private;
 	syslog(LOG_INFO, "No longer monitoring snapshot %s\n",
 	       device);
+
+	dm_free(state);
 	dmeventd_lvm2_exit();
 	return 1;
 }
--- LVM2/test/shell/lvextend-snapshot-dmeventd.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvextend-snapshot-dmeventd.sh	2011/11/21 12:31:21	1.2
@@ -27,7 +27,7 @@
 
 which mkfs.ext2 || exit 200
 
-aux prepare_vg 2
+aux prepare_vg 3
 aux prepare_dmeventd
 
 lvcreate -l 8 -n base $vg
@@ -44,8 +44,19 @@
 post=`percent`
 
 test $pre = $post
+
 write 2 5000
 pre=`percent`
 sleep 10 # dmeventd only checks every 10 seconds :(
 post=`percent`
 test $pre -gt $post
+
+# check that a second extension happens; we used to fail to extend when the
+# utilisation ended up between THRESH and (THRESH + 10)... see RHBZ 754198
+# (the utilisation after the write should be 57 %)
+
+write 3 5000
+pre=`percent`
+sleep 10 # dmeventd only checks every 10 seconds :(
+post=`percent`
+test $pre -gt $post


