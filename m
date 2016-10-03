From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Oct 2016 15:51:03 +0000 (UTC)
Subject: master - raid: dmeventd plugin use 64bit arithmetic
Message-ID: <20161003155103.6C51860A70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee04f1fcfd915af927ad19c3952e211158f4df0d
Commit:        ee04f1fcfd915af927ad19c3952e211158f4df0d
Parent:        e95a2529748c3047f1af33678c74114d71994e05
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 3 14:58:23 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 3 17:44:25 2016 +0200

raid: dmeventd plugin use 64bit arithmetic

Coverity suggested to used 64bit unsigned ints instead of signed 32b int.
Assuming there is no user of >31legs raid array.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ed07307..6186737 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Use unsigned math when checking more then 31 legs of raid.
   Fix 'dmstats delete' with dmsetup older than v1.02.129
   Fix stats walk segfault with dmsetup older than v1.02.129
 
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index bec594a..ee18793 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -48,11 +48,11 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 	while ((d = strchr(d, 'D'))) {
 		uint32_t dev = (uint32_t)(d - status->dev_health);
 
-		if (!(state->raid_devs[dev / 64] & (1 << (dev % 64))))
+		if (!(state->raid_devs[dev / 64] & (UINT64_C(1) << (dev % 64))))
 			log_error("Device #%u of %s array, %s, has failed.",
 				  dev, status->raid_type, device);
 
-		state->raid_devs[dev / 64] |= (1 << (dev % 64));
+		state->raid_devs[dev / 64] |= (UINT64_C(1) << (dev % 64));
 		d++;
 		dead = 1;
 	}


