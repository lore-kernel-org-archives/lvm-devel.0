From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Dec 2016 14:15:19 +0000 (UTC)
Subject: master - cleanup: easier code for raid plugin
Message-ID: <20161209141519.B12FA602B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9c6c115d3cfd203e99561d500293dbfc8662f49
Commit:        f9c6c115d3cfd203e99561d500293dbfc8662f49
Parent:        15e4ab3e9375b561880fa83f0a5a3c438e192bcc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 9 13:58:19 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 9 15:15:02 2016 +0100

cleanup: easier code for raid plugin

Set bits only when then were not yet assigned.
---
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index a207c99..911ae7a 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -38,6 +38,7 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 	struct dm_status_raid *status;
 	const char *d;
 	int dead = 0, r = 1;
+	uint32_t dev;
 
 	if (!dm_get_status_raid(state->mem, params, &status)) {
 		log_error("Failed to process status line for %s.", device);
@@ -46,24 +47,26 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 
 	d = status->dev_health;
 	while ((d = strchr(d, 'D'))) {
-		uint32_t dev = (uint32_t)(d - status->dev_health);
+		dev = (uint32_t)(d - status->dev_health);
 
-		if (!(state->raid_devs[dev / 64] & (UINT64_C(1) << (dev % 64))))
-			log_error("Device #%u of %s array, %s, has failed.",
-				  dev, status->raid_type, device);
+		if (!(state->raid_devs[dev / 64] & (UINT64_C(1) << (dev % 64)))) {
+			state->raid_devs[dev / 64] |= (UINT64_C(1) << (dev % 64));
+			log_warn("WARNING: Device #%u of %s array, %s, has failed.",
+				 dev, status->raid_type, device);
+		}
 
-		state->raid_devs[dev / 64] |= (UINT64_C(1) << (dev % 64));
 		d++;
 		dead = 1;
 	}
 
 	if (dead) {
 		if (status->insync_regions < status->total_regions) {
-			if (!state->warned)
+			if (!state->warned) {
+				state->warned = 1;
 				log_warn("WARNING: waiting for resynchronization to finish "
 					 "before initiating repair on RAID device %s.", device);
+			}
 
-			state->warned = 1;
 			goto out; /* Not yet done syncing with accessible devices */
 		}
 


