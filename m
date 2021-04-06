From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:28 +0000 (GMT)
Subject: main - polldaemon: improve support for interruptions
Message-ID: <20210406200728.7B5593858012@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d2522f4a05aa027bcc911ecb832450bc19b7fb57
Commit:        d2522f4a05aa027bcc911ecb832450bc19b7fb57
Parent:        ff8aaadec912398598fd4b16de99ed700b97b130
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 6 14:57:42 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 22:02:31 2021 +0200

polldaemon: improve support for interruptions

Enhance handling of interruptions of polling process and lvmpoll daemon.
Daemon should now react much faster on interrups (i.e. shutdown
sequence) and avoid taking lenghty sleep waiting on pvmove signaling.
---
 daemons/lvmpolld/lvmpolld-core.c |  6 ++----
 tools/polldaemon.c               | 35 ++++++++++++++++-------------------
 2 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index f7381eb35..ab8284145 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -149,7 +149,7 @@ static void _lvmpolld_global_unlock(struct lvmpolld_state *ls)
 static int _fini(struct daemon_state *s)
 {
 	int done;
-	const struct timespec t = { .tv_nsec = 250000000 }; /* .25 sec */
+	const struct timespec t = { .tv_nsec = 10000000 }; /* .01 sec */
 	struct lvmpolld_state *ls = s->private;
 
 	DEBUGLOG(s, "fini");
@@ -236,9 +236,7 @@ static int poll_for_output(struct lvmpolld_lv *pdlv, struct lvmpolld_thread_data
 	}
 
 	while (1) {
-		do {
-			r = poll(fds, 2, pdlv_get_timeout(pdlv) * 1000);
-		} while (r < 0 && errno == EINTR);
+		r = poll(fds, 2, pdlv_get_timeout(pdlv) * 1000);
 
 		DEBUGLOG(pdlv->ls, "%s: %s %d", PD_LOG_PREFIX, "poll() returned", r);
 		if (r < 0) {
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index c182e548e..a220d63a2 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -122,10 +122,12 @@ static void _nanosleep(unsigned secs, unsigned allow_zero_time)
 	if (!secs && !allow_zero_time)
 		wtime.tv_nsec = WAIT_AT_LEAST_NANOSECS;
 
-	while (!nanosleep(&wtime, &wtime) && errno == EINTR) {}
+	sigint_allow();
+	nanosleep(&wtime, &wtime);
+	sigint_restore();
 }
 
-static void _sleep_and_rescan_devices(struct cmd_context *cmd, struct daemon_parms *parms)
+static int _sleep_and_rescan_devices(struct cmd_context *cmd, struct daemon_parms *parms)
 {
 	if (!parms->aborting) {
 		/*
@@ -137,8 +139,12 @@ static void _sleep_and_rescan_devices(struct cmd_context *cmd, struct daemon_par
 		lvmcache_destroy(cmd, 1, 0);
 		label_scan_destroy(cmd);
 		_nanosleep(parms->interval, 0);
+		if (sigint_caught())
+			return_0;
 		lvmcache_label_scan(cmd);
 	}
+
+	return 1;
 }
 
 int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
@@ -150,14 +156,18 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 	uint32_t lockd_state = 0;
 	uint32_t error_flags = 0;
 	int ret;
+	unsigned wait_before_testing = parms->wait_before_testing;
 
-	if (!parms->wait_before_testing)
+	if (!wait_before_testing)
 		lvmcache_label_scan(cmd);
 
 	/* Poll for completion */
 	while (!finished) {
-		if (parms->wait_before_testing)
-			_sleep_and_rescan_devices(cmd, parms);
+		if (wait_before_testing &&
+		    !_sleep_and_rescan_devices(cmd, parms)) {
+			log_error("ABORTING: Polling interrupted for %s.", id->display_name);
+			return 0;
+		}
 
 		/*
 		 * An ex VG lock is needed because the check can call finish_copy
@@ -220,20 +230,7 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		if (!lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state))
 			stack;
 
-		/*
-		 * FIXME Sleeping after testing, while preferred, also works around
-		 * unreliable "finished" state checking in _percent_run.  If the
-		 * above _check_lv_status is deferred until after the first sleep it
-		 * may be that a polldaemon will run without ever completing.
-		 *
-		 * This happens when one snapshot-merge polldaemon is racing with
-		 * another (polling the same LV).  The first to see the LV status
-		 * reach the "finished" state will alter the LV that the other
-		 * polldaemon(s) are polling.  These other polldaemon(s) can then
-		 * continue polling an LV that doesn't have a "status".
-		 */
-		if (!parms->wait_before_testing && !finished)
-			_sleep_and_rescan_devices(cmd, parms);
+		wait_before_testing = 1;
 	}
 
 	return 1;


