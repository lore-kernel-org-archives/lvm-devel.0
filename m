From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 20 May 2015 17:48:09 +0000 (UTC)
Subject: master - metadata: Add pvs_outdated to struct volume_group.
Message-ID: <20150520174809.BE94660188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=611c8b6d29ca164a22270cb9b3dcf7958063c712
Commit:        611c8b6d29ca164a22270cb9b3dcf7958063c712
Parent:        5435346052f491333b79da48bec5ef160cd118d5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 15 16:41:09 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed May 20 19:46:14 2015 +0200

metadata: Add pvs_outdated to struct volume_group.

This is a list of PVs that should have their MDAs wiped because they carry
outdated metadata (that used to belong to the VG they are attached to).
---
 lib/metadata/metadata.c |    3 +++
 lib/metadata/vg.c       |    1 +
 lib/metadata/vg.h       |    7 +++++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5456c4e..8300eb6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3307,6 +3307,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				*consistent = _repair_inconsistent_vg(correct_vg);
 			else
 				*consistent = !reappeared;
+			if (_wipe_outdated_pvs(cmd, correct_vg, &correct_vg->pvs_outdated))
+				/* clear the list */
+				dm_list_init(&correct_vg->pvs_outdated);
 		}
 		return correct_vg;
 	}
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index c9a7e9e..1db8e75 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -61,6 +61,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->pvs_to_create);
+	dm_list_init(&vg->pvs_outdated);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_lvs);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index b0ab122..bb21f34 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -91,6 +91,13 @@ struct volume_group {
 	struct dm_list pvs_to_create;
 
 	/*
+	 * List of physical volumes that carry outdated metadata that belongs
+	 * to this VG. Currently only populated when lvmetad is in use.
+	 */
+
+	struct dm_list pvs_outdated;
+
+	/*
 	 * logical volumes
 	 * The following relationship should always hold:
 	 * dm_list_size(lvs) = user visible lv_count + snapshot_count + other invisible LVs


