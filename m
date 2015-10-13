From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:56 +0000 (UTC)
Subject: master - dmeventd: handle snapshot overflow
Message-ID: <20151013140356.BF53B61207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e261af52eb26c22aebd62cdbd8bb79c195274ee9
Commit:        e261af52eb26c22aebd62cdbd8bb79c195274ee9
Parent:        3f03d46fc13be2274b3c29d4fc97a3306bc33eda
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 9 21:41:50 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:15:44 2015 +0200

dmeventd: handle snapshot overflow

When snapshot reports overflow, handle it in the same way as Invalid.
Until better ideas are implemented.
---
 WHATS_NEW_DM                                       |    1 +
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ff4ac22..efe8b37 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Dmeventd handles snapshot overflow for now equally as invalid.
   Convert dmeventd to use common logging macro system from libdm.
   Return -ENOMEM when device registration fails instead of 0 (=success).
   Enforce writethrough mode for cleaner policy.
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index ffe6666..ae8e308 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -150,7 +150,7 @@ void process_event(struct dm_task *dmt,
 	if (!dm_get_status_snapshot(state->mem, params, &status))
 		goto out;
 
-	if (status->invalid) {
+	if (status->invalid || status->overflow) {
 		struct dm_info info;
 		log_error("Snapshot %s is lost.", device);
 		if (dm_task_get_info(dmt, &info)) {
@@ -170,7 +170,7 @@ void process_event(struct dm_task *dmt,
 	 * If the snapshot has been invalidated or we failed to parse
 	 * the status string. Report the full status string to syslog.
 	 */
-	if (status->invalid || !status->total_sectors) {
+	if (status->invalid || status->overflow || !status->total_sectors) {
 		log_error("Snapshot %s changed state to: %s.", device, params);
 		state->percent_check = 0;
 		goto out;


