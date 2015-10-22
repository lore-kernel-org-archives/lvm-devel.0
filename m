From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:30 +0000 (UTC)
Subject: master - dmeventd: raid plugin reporting
Message-ID: <20151022213330.D1B8B610C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c5c9e2355826ad3835f35e494dde9bb8b1e6356
Commit:        9c5c9e2355826ad3835f35e494dde9bb8b1e6356
Parent:        cde12cbe9e4d3cabefc8644846e86b73b6217b6d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 10:38:40 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:28:37 2015 +0200

dmeventd: raid plugin reporting

Fix raid logging introduced with last updating commit.
---
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index f00ffa4..2f200ba 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -37,14 +37,17 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 		return 0;
 	}
 
-	if ((d = strchr(status->dev_health, 'D')) && !state->failed) {
+	if ((d = strchr(status->dev_health, 'D'))) {
+		if (state->failed)
+			goto out; /* already reported */
+
 		log_error("Device #%d of %s array, %s, has failed.",
 			 (int)(d - status->dev_health),
 			 status->raid_type, device);
 
 		state->failed = 1;
 		if (!dmeventd_lvm2_run_with_lock(state->cmd_lvscan))
-			log_info("Re-scan of RAID device %s failed.", device);
+			log_warn("WARNING: Re-scan of RAID device %s failed.", device);
 
 		/* if repair goes OK, report success even if lvscan has failed */
 		if (!dmeventd_lvm2_run_with_lock(state->cmd_lvconvert)) {
@@ -58,7 +61,7 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 			 status->raid_type, device,
 			 (status->insync_regions == status->total_regions) ? "now" : "not");
 	}
-
+out:
 	dm_pool_free(state->mem, status);
 
 	return 1;


