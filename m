From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Aug 2014 12:17:30 +0000 (UTC)
Subject: master - thin: fix volume_list support
Message-ID: <20140826121730.7428861018@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0794a10f91557d58e865faff4c60aef6336ecf22
Commit:        0794a10f91557d58e865faff4c60aef6336ecf22
Parent:        1ee5e18a7b446bc08d99a5638fc4463e459b34d3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 26 12:10:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 26 14:10:18 2014 +0200

thin: fix volume_list support

Fixing problem, when user sets volume_list and excludes thin pools
from activation. In this case pool return 'success' for skipped activation.

We need to really check the volume it is actually active to properly
to remove queued pool messages. Otherwise the lvm2 and kernel
metadata started to go async since lvm2 believed, messages were submitted.

Add also better check for threshold when create a new thin volume.
In this case we require local activation of thin pool so we are able
to check pool fullness.
---
 WHATS_NEW                 |    1 +
 lib/metadata/lv_manip.c   |   10 +--------
 lib/metadata/thin_manip.c |   50 +++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 48 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 13e6129..9ddb232 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  Fix manipulation with thin-pools which are excluded via volume_list.
   Support lv/vgremove -ff to remove thin vols from broken/inactive thin pools.
   Fix typo breaking configure --with-lvm1=shared.
   Modify lvresize code to handle raid/mirrors and physical extents.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5cc0079..e57e7b3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6816,15 +6816,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		if (lv_is_active_locally(lvl->lv) &&
-		    !pool_below_threshold(first_seg(lvl->lv))) {
-			log_error("Cannot create thin volume. Pool \"%s/%s\" "
-				  "is filled over the autoextend threshold.",
-				  lvl->lv->vg->name, lvl->lv->name);
-			return NULL;
-		}
-
-		if ((lv_is_active(lvl->lv) || is_change_activating(lp->activate)) &&
+		if ((pool_is_active(lvl->lv) || is_change_activating(lp->activate)) &&
 		    !update_pool_lv(lvl->lv, 1))
 			return_NULL;
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index ae42da1..61e9c6e 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -307,9 +307,36 @@ uint32_t get_free_pool_device_id(struct lv_segment *thin_pool_seg)
 	return max_id;
 }
 
+static int _check_pool_create(const struct logical_volume *lv)
+{
+	const struct lv_thin_message *lmsg;
+	struct lvinfo info;
+
+	dm_list_iterate_items(lmsg, &first_seg(lv)->thin_messages) {
+		if (lmsg->type != DM_THIN_MESSAGE_CREATE_THIN)
+			continue;
+		/* When creating new thin LV, check for size would be needed */
+		if (!lv_info(lv->vg->cmd, lv, 1, &info, 0, 0) ||
+		    !info.exists) {
+			log_error("Pool %s needs to be locally active for threshold check.",
+				  display_lvname(lv));
+			return 0;
+		}
+		if (!pool_below_threshold(first_seg(lv))) {
+			log_error("Free space in pool %s is above threshold, new volumes are not allowed.",
+				  display_lvname(lv));
+			return 0;
+		}
+		break;
+	}
+
+	return 1;
+}
+
 int update_pool_lv(struct logical_volume *lv, int activate)
 {
 	int monitored;
+	int ret = 1;
 
 	if (!lv_is_thin_pool(lv)) {
 		log_error(INTERNAL_ERROR "Updated LV %s is not pool.", lv->name);
@@ -324,10 +351,24 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 		if (!lv_is_active(lv)) {
 			monitored = dmeventd_monitor_mode();
 			init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
-			if (!activate_lv_excl(lv->vg->cmd, lv))
+			if (!activate_lv_excl(lv->vg->cmd, lv)) {
+				init_dmeventd_monitor(monitored);
 				return_0;
-			if (!deactivate_lv(lv->vg->cmd, lv))
+			}
+			if (!lv_is_active(lv)) {
+				init_dmeventd_monitor(monitored);
+				log_error("Cannot activate thin pool %s, perhaps skipped in lvm.conf volume_list?",
+					  display_lvname(lv));
+				return 0;
+			}
+
+			if (!(ret = _check_pool_create(lv)))
+				stack;
+
+			if (!deactivate_lv(lv->vg->cmd, lv)) {
+				init_dmeventd_monitor(monitored);
 				return_0;
+			}
 			init_dmeventd_monitor(monitored);
 		}
 		/*
@@ -337,7 +378,8 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 		else if (!resume_lv_origin(lv->vg->cmd, lv)) {
 			log_error("Failed to resume %s.", lv->name);
 			return 0;
-		}
+		} else if (!(ret = _check_pool_create(lv)))
+			stack;
 	}
 
 	dm_list_init(&(first_seg(lv)->thin_messages));
@@ -345,7 +387,7 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
-	return 1;
+	return ret;
 }
 
 int update_thin_pool_params(struct volume_group *vg,


