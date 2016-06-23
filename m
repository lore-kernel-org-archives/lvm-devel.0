From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:30 +0000 (UTC)
Subject: master - monitoring: preserve monitoring status during update
Message-ID: <20160623130130.DAA2C605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc8c5c1886ea7c090a3bfa96de8f22ca060614ec
Commit:        dc8c5c1886ea7c090a3bfa96de8f22ca060614ec
Parent:        eb51be4fbee95d76b53e5255242a8032c3028aa2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 22 23:21:27 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:56:10 2016 +0200

monitoring: preserve monitoring status during update

Ignore monitoring during whole update (suspend/resume) of thin-pool.
---
 WHATS_NEW                 |    1 +
 lib/metadata/thin_manip.c |   21 +++++++++++++--------
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7cd46d1..e61fbb2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Preserve monitoring status when updating thin-pool metadata.
   Rerurn 0 (inactive) when status cannot be queried in _lv_active().
   Switch to log_warn() for failing activation status query.
   Refactor lvconvert argument handling code.
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index aa5f388..0d850d6 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -451,9 +451,15 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 
 	if (activate) {
 		/* If the pool is not active, do activate deactivate */
+		monitored = dmeventd_monitor_mode();
+		init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
 		if (!lv_is_active(lv)) {
-			monitored = dmeventd_monitor_mode();
-			init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
+			/*
+			 * FIXME:
+			 *   Rewrite activation code to handle whole tree of thinLVs
+			 *   as this version has major problem when it does not know
+			 *   which Node has pool active.
+			 */
 			if (!activate_lv_excl(lv->vg->cmd, lv)) {
 				init_dmeventd_monitor(monitored);
 				return_0;
@@ -481,13 +487,12 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 			}
 		}
 
-		if (activate) {
-			if (!deactivate_lv(lv->vg->cmd, lv)) {
-				log_error("Failed to deactivate %s.", display_lvname(lv));
-				ret = 0;
-			}
-			init_dmeventd_monitor(monitored);
+		if (activate &&
+		    !deactivate_lv(lv->vg->cmd, lv)) {
+			log_error("Failed to deactivate %s.", display_lvname(lv));
+			ret = 0;
 		}
+		init_dmeventd_monitor(monitored);
 
 		/* Unlock memory if possible */
 		memlock_unlock(lv->vg->cmd);


