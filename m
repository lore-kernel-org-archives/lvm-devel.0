From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 30 Jan 2015 13:16:45 +0000 (UTC)
Subject: master - raid: check lock holding LV
Message-ID: <20150130131645.872D0610A3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=434031719e37524606d198b2d78795962970a1b8
Commit:        434031719e37524606d198b2d78795962970a1b8
Parent:        c99cb207153b5c103889a1ac67f799f6af4687d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 30 14:13:25 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 30 14:16:27 2015 +0100

raid: check lock holding LV

Since raid could be used as stacked LV - check lock holding LV
for proper locking type for clustered usage.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c7e257b..45e01fb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Check lock holding LV when lvconverting stacked raid LV in cluster.
   Support "udev" ext. dev. info for filters: PV min size, mpath, md, partition.
   Add fw_raid_component_detection lvm.conf option to enable FW raid detection.
   Add devices/external_device_info_source lvm.conf option ("none" by default).
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 4ce84a0..c786e89 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1040,8 +1040,8 @@ int lv_raid_change_image_count(struct logical_volume *lv,
 	/*
 	 * LV must be either in-active or exclusively active
 	 */
-	if (lv_is_active(lv) && vg_is_clustered(lv->vg) &&
-	    !lv_is_active_exclusive_locally(lv)) {
+	if (lv_is_active(lv_lock_holder(lv)) && vg_is_clustered(lv->vg) &&
+	    !lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
 		log_error("%s/%s must be active exclusive locally to"
 			  " perform this operation.", lv->vg->name, lv->name);
 		return 0;


