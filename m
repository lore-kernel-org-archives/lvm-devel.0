From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:21 +0000 (UTC)
Subject: master - raid: drop invalid modication of active parameter
Message-ID: <20140211180121.7562F60D1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=38e457c4788d0d2e51bf46edbd82b4683d33ac8f
Commit:        38e457c4788d0d2e51bf46edbd82b4683d33ac8f
Parent:        8a21dcebac02884615b80fbe9d276991a50dc66b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 11 13:34:22 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 18:48:38 2014 +0100

raid: drop invalid modication of active parameter

lv_active_change will enforce proper activation.
Modification of activation was wrong and lead to misuse of
autoactivation. Fix allows to use proper local exclusive activation,
while the removed code turned this into just exclusive
activation (losing required local property).
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    8 --------
 2 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a64f961..c8f622a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Use local exclusive activation for creation of raid in cluster.
   Use correctly signed 64b constant when selecting raid volumes.
   Add systemd native service for clvmd, cmirrord and clustered LV activation.
   Remove ExecReload from lvmetad systemd unit: lvmetad -R undefined. (2.02.98)
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d0b6c9e..1b9a7ae 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6153,14 +6153,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	} else if (seg_is_raid(lp)) {
 		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
 		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
-		if (vg_is_clustered(lv->vg) &&
-		    is_change_activating(lp->activate) &&
-		    (lp->activate != CHANGE_AE)) {
-			log_debug_activation("Creating RAID logical volume in a"
-					     " cluster: setting activation"
-					     " mode to EX");
-			lp->activate = CHANGE_AE;
-		}
 	}
 
 	if (lp->cache) {


