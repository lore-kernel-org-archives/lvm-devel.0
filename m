From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:07 +0000 (UTC)
Subject: master - archiver: add check for dm_pool_strdup
Message-ID: <20131122200907.2FF2661133@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=782a356e7cce8d0d32850677cdb5a9b28996471e
Commit:        782a356e7cce8d0d32850677cdb5a9b28996471e
Parent:        d079c81ab49648fc5506490e34e16244c20fa45f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 13:12:35 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:54 2013 +0100

archiver: add check for dm_pool_strdup

It will likely not fail to duplicate empty string, but
just keep the test of result of this function consistent.

Also on error path restore extent_size if in some
case someone would still use that variable.
---
 lib/format_text/archiver.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index f41bffc..c1fe3f5 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -334,13 +334,17 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg, int drop
 	 * Setting vg->old_name to a blank value will explicitly
 	 * disable any attempt to check VG name in existing metadata.
 	*/
-	vg->old_name = dm_pool_strdup(vg->vgmem, "");
+	if (!(vg->old_name = dm_pool_strdup(vg->vgmem, ""))) {
+		log_error("Failed to duplicate empty name.");
+		return 0;
+	}
 
 	/* Add any metadata areas on the PVs */
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		tmp = vg->extent_size;
 		vg->extent_size = 0;
 		if (!vg->fid->fmt->ops->pv_setup(vg->fid->fmt, pvl->pv, vg)) {
+			vg->extent_size = tmp;
 			log_error("Format-specific setup for %s failed",
 				  pv_dev_name(pvl->pv));
 			return 0;


