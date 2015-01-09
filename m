From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 Jan 2015 13:10:49 +0000 (UTC)
Subject: master - metadata: add "Failed to write VG <vg_name>." on failed vg_write and revert previous patch
Message-ID: <20150109131049.1F96560921@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb7e2ff49368e547d597baf263e8cb7cca8b63fb
Commit:        fb7e2ff49368e547d597baf263e8cb7cca8b63fb
Parent:        db7351d3133e237db01361fed8efd6b0fac85c32
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 9 14:04:44 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 9 14:04:44 2015 +0100

metadata: add "Failed to write VG <vg_name>." on failed vg_write and revert previous patch

Better than previous patch which changed log_warn to log_error -
we can have multiple MDAs and if one of them fails to be written,
we can still continue with other MDAs if we're in a mode where
we can handle missing PVs - so keep the log_warn for single
failed MDA write as it was before.

However, add log_error with "Failed to write VG <vg_name>." in
case we're not handling missing PVs or no MDA was written at all
during VG write process. This also prevents an internal error in
which the vg_write fails and we're not issuing any other log_error
in vg_write caller or above, so we end up with:
  "Internal error: Failed command did not use log_error".
---
 lib/metadata/metadata.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 39bd325..465eb84 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2795,7 +2795,7 @@ int vg_write(struct volume_group *vg)
 		}
 		if (!mda->ops->vg_write(vg->fid, vg, mda)) {
 			if (vg->cmd->handles_missing_pvs) {
-				log_error("Failed to write an MDA of VG %s.", vg->name);
+				log_warn("WARNING: Failed to write an MDA of VG %s.", vg->name);
 				mda->status |= MDA_FAILED;
 			} else {
 				stack;
@@ -2807,6 +2807,7 @@ int vg_write(struct volume_group *vg)
 	}
 
 	if (revert || !wrote) {
+		log_error("Failed to write VG %s.", vg->name);
 		dm_list_uniterate(mdah, &vg->fid->metadata_areas_in_use, &mda->list) {
 			mda = dm_list_item(mdah, struct metadata_area);
 


