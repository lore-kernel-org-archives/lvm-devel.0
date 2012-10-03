From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  3 Oct 2012 20:56:56 +0000 (UTC)
Subject: master - RAID: Do not allow RAID LVs in a cluster volume group.
Message-ID: <20121003205656.0B5CA247D@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9efd3fb604ae34803bb2d4c94080c57d3efdba81
Commit:        9efd3fb604ae34803bb2d4c94080c57d3efdba81
Parent:        a27650cc983d54767316998e1df472325d169617
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Oct 3 15:52:54 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Oct 3 15:52:54 2012 -0500

RAID:  Do not allow RAID LVs in a cluster volume group.

It would be possible to activate a RAID LV exclusively in a cluster
volume group, but for now we do not allow RAID LVs to exist in a
clustered volume group at all.  This has two components:
	1) Do not allow RAID LVs to be created in a clustered VG
	2) Do not allow changing a VG from single-machine to clustered
	   if there are RAID LVs present.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   19 +++++++++++++++++--
 lib/metadata/vg.c       |   13 ++++++++++++-
 3 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cd325b9..18e860c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Do not allow RAID LVs in a clustered volume group.
   Update lvconvert to support stacking of devs for thin meta/data devs.
   Support changes of permissions for thin snapshot volumes.
   Enhance insert_layer_for_lv() with recursive rename for _tdata LVs.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4f86d14..d469fe8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4438,10 +4438,25 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		if (!(lvl = find_lv_in_vg(vg, lp->pool))) {
 			log_error("Unable to find existing pool LV %s in VG %s.",
 				  lp->pool, vg->name);
-			return 0;
+			return NULL;
 		}
 		if (!update_pool_lv(lvl->lv, 1))
-			return_0;
+			return_NULL;
+	}
+
+	if (vg_is_clustered(vg) && segtype_is_raid(lp->segtype)) {
+		/*
+		 * FIXME:
+		 * We could allow a RAID LV to be created as long as it
+		 * is activated exclusively.  Any subsequent activations
+		 * would have to be enforced as exclusive also.
+		 *
+		 * For now, we disallow the existence of RAID LVs in a
+		 * cluster VG
+		 */
+		log_error("Unable to create a %s logical volume in a cluster.",
+			  lp->segtype->name);
+		return NULL;
 	}
 
 	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 29e9aa4..2897d42 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -514,9 +514,20 @@ int vg_set_clustered(struct volume_group *vg, int clustered)
 
 	/*
 	 * We do not currently support switching the cluster attribute
-	 * on active mirrors or snapshots.
+	 * on active mirrors, snapshots or RAID logical volumes.
 	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
+		/*
+		 * FIXME:
+		 * We could allow exclusive activation of RAID LVs, but
+		 * for now we disallow them in a cluster VG at all.
+		 */
+		if (lv_is_raid_type(lvl->lv)) {
+			log_error("RAID logical volumes are not allowed "
+				  "in a cluster volume group.");
+			return 0;
+		}
+
 		if (lv_is_active(lvl->lv) &&
 		    (lv_is_mirrored(lvl->lv) || lv_is_raid_type(lvl->lv))) {
 			log_error("%s logical volumes must be inactive "


