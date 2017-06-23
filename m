From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 18:08:20 -0400
Subject: master - dmeventd: improve more raid status reporting
Message-ID: <201706232208.v5NM8KXU026665@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0016b79c8b3223de7155fb4ec5fa799f7af1c811
Commit:        0016b79c8b3223de7155fb4ec5fa799f7af1c811
Parent:        2a50a28f3e8e5a1a7ecbf247f27cc8178ee286bf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 00:06:12 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jun 24 00:06:12 2017 +0200

dmeventd: improve more raid status reporting

When we want to report primary leg failure, check for intial 'a',
since otherwice 'Aa idle' is normally visible.

Also reset array of bit flags marking dead devices, once
plugin detects raid is in sync.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3e0e8a5..83df7cc 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.141 - 
 ===============================
+  Reset array with dead rimage devices once raid gets in sync.
   Drop unneeded --config option from raid dmeventd plugin.
   dm_get_status_raid() handle better some incosistent md statuses.
   Accept truncated files in calls to dm_stats_update_regions_from_fd().
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 666362a..52cf43d 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -68,7 +68,8 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 	 * This is simply the way the kernel works...
 	 */
 	if (!strcmp(status->sync_action, "idle") &&
-	    strchr(status->dev_health, 'a')) {
+	    (status->dev_health[0] == 'a') &&
+	    (status->insync_regions < status->total_regions)) {
 		log_error("Primary sources for new RAID, %s, have failed.",
 			  device);
 		dead = 1; /* run it through LVM repair */
@@ -97,6 +98,8 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 		}
 	} else {
 		state->failed = 0;
+		if (status->insync_regions == status->total_regions)
+			memset(&state->raid_devs, 0, sizeof(state->raid_devs));
 		log_info("%s array, %s, is %s in-sync.",
 			 status->raid_type, device,
 			 (status->insync_regions == status->total_regions) ? "now" : "not");


