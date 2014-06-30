From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 30 Jun 2014 10:25:15 +0000 (UTC)
Subject: master - thin: repaired LV uses _meta%d
Message-ID: <20140630102515.5E0CD60F5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eadcea2dae8c56e96b694cb388999865d2678e22
Commit:        eadcea2dae8c56e96b694cb388999865d2678e22
Parent:        b6fe906956cb7bdaa9b3ef43c14f8e6155483d7e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 30 11:01:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 30 12:15:13 2014 +0200

thin: repaired LV uses _meta%d

Don't leave 'regular' LV with reserved suffix for a user.
After succefull repair use 'normal' (non-reserved) LV name
for backup of original metadata.
---
 WHATS_NEW          |    1 +
 man/lvconvert.8.in |    2 +-
 tools/lvconvert.c  |    8 ++++----
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 396dd07..b8b2951 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Leave backup pool metadata with _meta%d suffix instead of reserved _tmeta%d.
   Allow RAID repair to reuse PVs from same image that suffered a failure.
   New RAID images now avoid allocation on any PVs in the same parent RAID LV.
   Always reevaluate filters just before creating PV.
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 76003b4..f96cee2 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -380,7 +380,7 @@ Only inactive thin pool volumes can be repaired.
 There is no validation of metadata between kernel and lvm2.
 This requires further manual work.
 After successfull repair the old unmodified metadata are still
-available in \fB<pool>_tmeta<n>\fP LV.
+available in \fB<pool>_meta<n>\fP LV.
 .TP
 .B \-\-replace \fIPhysicalVolume
 Remove the specified device (\fIPhysicalVolume\fP) and replace it with one
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a2e02d4..9f2d114 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2468,8 +2468,8 @@ deactivate_pmslv:
 	if (!handle_pool_metadata_spare(pool_lv->vg, 0, NULL, 1))
 		stack;
 
-	if (dm_snprintf(meta_path, sizeof(meta_path), "%s%%d", mlv->name) < 0) {
-		log_error("Can't prepare new name for %s.", mlv->name);
+	if (dm_snprintf(meta_path, sizeof(meta_path), "%s_meta%%d", pool_lv->name) < 0) {
+		log_error("Can't prepare new metadata name for %s.", pool_lv->name);
 		return 0;
 	}
 
@@ -2488,7 +2488,7 @@ deactivate_pmslv:
 	if (!attach_pool_metadata_lv(first_seg(pool_lv), pmslv))
 		return_0;
 
-	/* Used _tmeta will become visible  _tmeta%d */
+	/* Used _tmeta will become visible  _meta%d */
 	if (!lv_rename_update(cmd, mlv, pms_path, 0))
 		return_0;
 
@@ -2499,7 +2499,7 @@ deactivate_pmslv:
 		 mlv->vg->name, mlv->name);
 
 	log_warn("WARNING: Use pvmove command to move \"%s/%s\" on the best fitting PV.",
-		 mlv->vg->name, first_seg(pool_lv)->metadata_lv->name);
+		 pool_lv->vg->name, first_seg(pool_lv)->metadata_lv->name);
 
 	return 1;
 }


