From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:02 +0000 (UTC)
Subject: dev-mornfall-activate - dmeventd: use dm_get_status_snapshot()
Message-ID: <20130604192702.83A8761182@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e992cb253cb4c9bf027dd7852d4399d2b439621c
Commit:        e992cb253cb4c9bf027dd7852d4399d2b439621c
Parent:        06e8ff29ff59a1893312f5b2d5e818c8c62ee7b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 26 17:07:08 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 27 10:33:06 2013 +0200

dmeventd: use dm_get_status_snapshot()

Switch to use libdm dm_get_status_snapshot() function for
reading status info.
This fixes bug, where the code was using 32bit integers,
while the snapshot target is able to return 64bit sizes.
However this also means, someone is using >1TB snapshot
cow devices, which is actually very bad idea anyway, since the
perfomance and memory usage in this case is very bad.
---
 WHATS_NEW_DM                                       |    1 +
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |   79 ++++++--------------
 2 files changed, 24 insertions(+), 56 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 99e8269..6dcf9f8 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Fix parsing of 64bit snapshot status in dmeventd snapshot plugin.
   Add dm_get_status_snapshot() for parsing snapshot status.
   Detecte mounted fs also via reading /proc/self/mountinfo.
   Add dm_mountinfo_read() for parsing /proc/self/mountinfo.
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 205218a..ac33ef3 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -32,52 +32,13 @@
 
 #define UMOUNT_COMMAND "/bin/umount"
 
-struct snap_status {
-	int invalid;
-	int used;
-	int max;
-};
-
 struct dso_state {
+	struct dm_pool *mem;
 	int percent_check;
-	int known_size;
+	uint64_t known_size;
 	char cmd_str[1024];
 };
 
-/* FIXME possibly reconcile this with target_percent when we gain
-   access to regular LVM library here. */
-static void _parse_snapshot_params(char *params, struct snap_status *status)
-{
-	char *p;
-	/*
-	 * xx/xx	-- fractions used/max
-	 * Invalid	-- snapshot invalidated
-	 * Unknown	-- status unknown
-	 */
-	status->used = status->max = 0;
-
-	if (!strncmp(params, "Invalid", 7)) {
-		status->invalid = 1;
-		return;
-	}
-
-	/*
-	 * When we return without setting non-zero max, the parent is
-	 * responsible for reporting errors.
-	 */
-	if (!strncmp(params, "Unknown", 7))
-		return;
-
-	if (!(p = strstr(params, "/")))
-		return;
-
-	*p = '\0';
-	p++;
-
-	status->used = atoi(params);
-	status->max = atoi(p);
-}
-
 static int _run(const char *cmd, ...)
 {
         va_list ap;
@@ -171,9 +132,9 @@ void process_event(struct dm_task *dmt,
 	uint64_t start, length;
 	char *target_type = NULL;
 	char *params;
-	struct snap_status status = { 0 };
+	struct dm_status_snapshot *status = NULL;
 	const char *device = dm_task_get_name(dmt);
-	int percent;
+	uint64_t percent;
 	struct dso_state *state = *private;
 
 	/* No longer monitoring, waiting for remove */
@@ -186,34 +147,35 @@ void process_event(struct dm_task *dmt,
 	if (!target_type)
 		goto out;
 
-	_parse_snapshot_params(params, &status);
+	if (!dm_get_status_snapshot(state->mem, params, &status))
+		goto out;
 
-	if (status.invalid) {
+	if (status->invalid) {
 		struct dm_info info;
 		if (dm_task_get_info(dmt, &info)) {
 			dmeventd_lvm2_unlock();
 			_umount(device, info.major, info.minor);
-                        return;
+			return;
 		} /* else; too bad, but this is best-effort thing... */
 	}
 
 	/* Snapshot size had changed. Clear the threshold. */
-	if (state->known_size != status.max) {
+	if (state->known_size != status->total_sectors) {
 		state->percent_check = CHECK_MINIMUM;
-		state->known_size = status.max;
+		state->known_size = status->total_sectors;
 	}
 
 	/*
 	 * If the snapshot has been invalidated or we failed to parse
 	 * the status string. Report the full status string to syslog.
 	 */
-	if (status.invalid || !status.max) {
+	if (status->invalid || !status->total_sectors) {
 		syslog(LOG_ERR, "Snapshot %s changed state to: %s\n", device, params);
 		state->percent_check = 0;
 		goto out;
 	}
 
-	percent = 100 * status.used / status.max;
+	percent = 100 * status->used_sectors / status->total_sectors;
 	if (percent >= state->percent_check) {
 		/* Usage has raised more than CHECK_STEP since the last
 		   time. Run actions. */
@@ -227,6 +189,8 @@ void process_event(struct dm_task *dmt,
 	}
 
 out:
+	if (status)
+		dm_pool_free(state->mem, status);
 	dmeventd_lvm2_unlock();
 }
 
@@ -236,28 +200,31 @@ int register_device(const char *device,
 		    int minor __attribute__((unused)),
 		    void **private)
 {
+	struct dm_pool *statemem = NULL;
 	struct dso_state *state;
 
 	if (!dmeventd_lvm2_init())
 		goto out;
 
-	if (!(state = dm_zalloc(sizeof(*state))))
+	if (!(statemem = dm_pool_create("snapshot_state", 512)) ||
+	    !(state = dm_pool_zalloc(statemem, sizeof(*state))))
 		goto bad;
 
-	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(),
-                                   state->cmd_str, sizeof(state->cmd_str),
+	if (!dmeventd_lvm2_command(statemem, state->cmd_str,
+				   sizeof(state->cmd_str),
 				   "lvextend --use-policies", device))
 		goto bad;
 
+	state->mem = statemem;
 	state->percent_check = CHECK_MINIMUM;
-	state->known_size = 0;
 	*private = state;
 
 	syslog(LOG_INFO, "Monitoring snapshot %s\n", device);
 
 	return 1;
 bad:
-	dm_free(state);
+	if (statemem)
+		dm_pool_destroy(statemem);
 	dmeventd_lvm2_exit();
 out:
 	syslog(LOG_ERR, "Failed to monitor snapshot %s.\n", device);
@@ -274,7 +241,7 @@ int unregister_device(const char *device,
 	struct dso_state *state = *private;
 
 	syslog(LOG_INFO, "No longer monitoring snapshot %s\n", device);
-	dm_free(state);
+	dm_pool_destroy(state->mem);
 	dmeventd_lvm2_exit();
 
 	return 1;


