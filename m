From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2010 12:55:21 -0000
Subject: LVM2/daemons/dmeventd/plugins/snapshot dmevent ...
Message-ID: <20100215125521.32145.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-02-15 12:55:20

Modified files:
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 

Log message:
	Rename "stat" to "status" in dmeventd_snapshot.c.
	
	Otherwise "warning: declaration of ???stat??? shadows a global declaration"
	will appear because it shadows "stat" from stat.h.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/01/22 12:48:58	1.7
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/02/15 12:55:20	1.8
@@ -38,7 +38,7 @@
 
 /* FIXME possibly reconcile this with target_percent when we gain
    access to regular LVM library here. */
-static void _parse_snapshot_params(char *params, struct snap_status *stat)
+static void _parse_snapshot_params(char *params, struct snap_status *status)
 {
 	char *p;
 	/*
@@ -46,10 +46,10 @@
 	 * Invalid	-- snapshot invalidated
 	 * Unknown	-- status unknown
 	 */
-	stat->used = stat->max = 0;
+	status->used = status->max = 0;
 
 	if (!strncmp(params, "Invalid", 7)) {
-		stat->invalid = 1;
+		status->invalid = 1;
 		return;
 	}
 
@@ -66,8 +66,8 @@
 	*p = '\0';
 	p++;
 
-	stat->used = atoi(params);
-	stat->max = atoi(p);
+	status->used = atoi(params);
+	status->max = atoi(p);
 }
 
 void process_event(struct dm_task *dmt,
@@ -78,7 +78,7 @@
 	uint64_t start, length;
 	char *target_type = NULL;
 	char *params;
-	struct snap_status stat = { 0 };
+	struct snap_status status = { 0 };
 	const char *device = dm_task_get_name(dmt);
 	int percent, *percent_warning = (int*)private;
 
@@ -92,18 +92,18 @@
 	if (!target_type)
 		goto out;
 
-	_parse_snapshot_params(params, &stat);
+	_parse_snapshot_params(params, &status);
 	/*
 	 * If the snapshot has been invalidated or we failed to parse
 	 * the status string. Report the full status string to syslog.
 	 */
-	if (stat.invalid || !stat.max) {
+	if (status.invalid || !status.max) {
 		syslog(LOG_ERR, "Snapshot %s changed state to: %s\n", device, params);
 		*percent_warning = 0;
 		goto out;
 	}
 
-	percent = 100 * stat.used / stat.max;
+	percent = 100 * status.used / status.max;
 	if (percent >= *percent_warning) {
 		syslog(LOG_WARNING, "Snapshot %s is now %i%% full.\n", device, percent);
 		/* Print warning on the next multiple of WARNING_STEP. */


