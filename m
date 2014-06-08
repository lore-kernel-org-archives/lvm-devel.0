From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun,  8 Jun 2014 19:12:01 +0000 (UTC)
Subject: master - metadata: Make it possible to write partial VGs obtained from lvmetad.
Message-ID: <20140608191201.7DEC261200@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dba6dec661c6a0193d9d713c6fd0b9b008c0f26a
Commit:        dba6dec661c6a0193d9d713c6fd0b9b008c0f26a
Parent:        943f3aec3d20169045ec2d2f4a07d87827cb95d8
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 26 14:23:33 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Jun 8 17:41:11 2014 +0200

metadata: Make it possible to write partial VGs obtained from lvmetad.

---
 lib/metadata/metadata.c |   47 ++++++++++++++++++++++++++++-------------------
 lib/metadata/metadata.h |    1 +
 2 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index fd81c1b..15f9249 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2613,6 +2613,7 @@ int vg_write(struct volume_group *vg)
 	struct dm_list *mdah;
         struct pv_to_create *pv_to_create;
 	struct metadata_area *mda;
+	int revert = 0, wrote = 0;
 
 	if (!vg_validate(vg))
 		return_0;
@@ -2665,39 +2666,45 @@ int vg_write(struct volume_group *vg)
 		if (!mda->ops->vg_write) {
 			log_error("Format does not support writing volume"
 				  "group metadata areas");
-			/* Revert */
-			dm_list_uniterate(mdah, &vg->fid->metadata_areas_in_use, &mda->list) {
-				mda = dm_list_item(mdah, struct metadata_area);
-
-				if (mda->ops->vg_revert &&
-				    !mda->ops->vg_revert(vg->fid, vg, mda)) {
-					stack;
-				}
-			}
-			return 0;
+			revert = 1;
+			break;
 		}
 		if (!mda->ops->vg_write(vg->fid, vg, mda)) {
-			stack;
-			/* Revert */
-			dm_list_uniterate(mdah, &vg->fid->metadata_areas_in_use, &mda->list) {
-				mda = dm_list_item(mdah, struct metadata_area);
+			if (vg->cmd->handles_missing_pvs) {
+				log_warn("WARNING: Failed to write an MDA of VG %s.", vg->name);
+				mda->status |= MDA_FAILED;
+			} else {
+				stack;
+				revert = 1;
+				break;
+			}
+		} else
+			++ wrote;
+	}
 
-				if (mda->ops->vg_revert &&
-				    !mda->ops->vg_revert(vg->fid, vg, mda)) {
-					stack;
-				}
+	if (revert || !wrote) {
+		dm_list_uniterate(mdah, &vg->fid->metadata_areas_in_use, &mda->list) {
+			mda = dm_list_item(mdah, struct metadata_area);
+
+			if (mda->ops->vg_revert &&
+			    !mda->ops->vg_revert(vg->fid, vg, mda)) {
+				stack;
 			}
-			return 0;
 		}
+		return 0;
 	}
 
 	/* Now pre-commit each copy of the new metadata */
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+		if (mda->status & MDA_FAILED)
+			continue;
 		if (mda->ops->vg_precommit &&
 		    !mda->ops->vg_precommit(vg->fid, vg, mda)) {
 			stack;
 			/* Revert */
 			dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+				if (mda->status & MDA_FAILED)
+					continue;
 				if (mda->ops->vg_revert &&
 				    !mda->ops->vg_revert(vg->fid, vg, mda)) {
 					stack;
@@ -2738,6 +2745,8 @@ static int _vg_commit_mdas(struct volume_group *vg)
 
 	/* Commit to each copy of the metadata area */
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+		if (mda->status & MDA_FAILED)
+			continue;
 		failed = 0;
 		if (mda->ops->vg_commit &&
 		    !mda->ops->vg_commit(vg->fid, vg, mda)) {
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index ed78cb6..4c5ad33 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -154,6 +154,7 @@ struct metadata_area_ops {
 
 #define MDA_IGNORED      0x00000001
 #define MDA_INCONSISTENT 0x00000002
+#define MDA_FAILED       0x00000004
 
 struct metadata_area {
 	struct dm_list list;


