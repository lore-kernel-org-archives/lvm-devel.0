From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:53:03 -0400
Subject: [PATCH 32/38] Update check in vg_split_mdas to account for ignored mdas list.
In-Reply-To: <1277520789-6808-32-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-11-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-12-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-13-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-14-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-15-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-16-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-17-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-18-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-19-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-20-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-21-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-22-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-23-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-24-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-25-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-26-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-27-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-28-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-29-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-30-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-31-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-32-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-33-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The check in vg_split_mdas will trigger an error if the 'from' vg
list is empty.  However, this might be ok in some instances now
that we have ignored mdas.  Relax this check so an error is triggered
only in the case where there's truly no more mdas in the 'from'
vg.

One example of where this makes a difference is with vgreduce.
If we try to vgreduce a PV with un-ignored mdas, this should trigger
the balancing function to un-ignore mdas on another PV in the VG.
However, we don't get to vg_write() before we fail because this
list size check fails, and we see an error message indicating:
"Cannot remove final metadata area ..."

Another example is with vgsplit into a new VG, where the PVs
being moved contain all ignored mdas.  We must move the mdas on
fid->metadata_areas_ignored from 'vg_from' to 'vg_to'.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   40 ++++++++++++++++++++++++++++------------
 1 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 58060f7..a50b89f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1364,20 +1364,12 @@ int vg_set_clustered(struct volume_group *vg, int clustered)
 	return 1;
 }
 
-/*
- * Separate metadata areas after splitting a VG.
- * Also accepts orphan VG as destination (for vgreduce).
- */
-int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
-		  struct volume_group *vg_from, struct volume_group *vg_to)
+static int _move_mdas(struct volume_group *vg_from, struct volume_group *vg_to,
+		      struct dm_list *mdas_from, struct dm_list *mdas_to)
 {
 	struct metadata_area *mda, *mda2;
-	struct dm_list *mdas_from, *mdas_to;
 	int common_mda = 0;
 
-	mdas_from = &vg_from->fid->metadata_areas;
-	mdas_to = &vg_to->fid->metadata_areas;
-
 	dm_list_iterate_items_safe(mda, mda2, mdas_from) {
 		if (!mda->ops->mda_in_vg) {
 			common_mda = 1;
@@ -1391,9 +1383,33 @@ int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
 				dm_list_move(mdas_to, &mda->list);
 		}
 	}
+	return common_mda;
+}
+
+/*
+ * Separate metadata areas after splitting a VG.
+ * Also accepts orphan VG as destination (for vgreduce).
+ */
+int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
+		  struct volume_group *vg_from, struct volume_group *vg_to)
+{
+	struct dm_list *mdas_from, *mdas_to;
+	struct dm_list *mdas_from_ignored, *mdas_to_ignored;
+	int common_mda = 0;
+
+	mdas_from = &vg_from->fid->metadata_areas;
+	mdas_from_ignored = &vg_from->fid->metadata_areas_ignored;
+	mdas_to = &vg_to->fid->metadata_areas;
+	mdas_to_ignored = &vg_to->fid->metadata_areas_ignored;
+
+	common_mda = _move_mdas(vg_from, vg_to,
+				mdas_from, mdas_to);
+	common_mda = _move_mdas(vg_from, vg_to,
+				mdas_from_ignored, mdas_to_ignored);
 
-	if (dm_list_empty(mdas_from) ||
-	    (!is_orphan_vg(vg_to->name) && dm_list_empty(mdas_to)))
+	if ((dm_list_empty(mdas_from) && dm_list_empty(mdas_from_ignored)) ||
+	    ((!is_orphan_vg(vg_to->name) && dm_list_empty(mdas_to) &&
+	      dm_list_empty(mdas_to_ignored))))
 		return common_mda;
 
 	return 1;
-- 
1.6.0.6


