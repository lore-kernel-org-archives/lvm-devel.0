From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:36 +0000 (UTC)
Subject: master - format1: check for lvm1_system_id
Message-ID: <20150508131636.5E88060759@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=950a21d58adc581f921847f5c356a45f4f9cce94
Commit:        950a21d58adc581f921847f5c356a45f4f9cce94
Parent:        05934d2538b76134fe4a5f4ddd7954ff32620b50
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 13:09:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 15:15:10 2015 +0200

format1: check for lvm1_system_id

As in the code above in this function continue to check for
lvm1_system_id pointer existance before dereferencing it
(Coverity).
---
 lib/format1/import-export.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 9b387e2..72f6946 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -180,7 +180,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 	}
 
 	/* Is VG being imported? */
-	if (vg && !vg_is_exported(vg) && *vg->lvm1_system_id &&
+	if (vg && !vg_is_exported(vg) && vg->lvm1_system_id && *vg->lvm1_system_id &&
 	    !strncmp(vg->lvm1_system_id, EXPORTED_TAG, sizeof(EXPORTED_TAG) - 1)) {
 		if (!generate_lvm1_system_id(cmd, (char *)pvd->system_id, IMPORTED_TAG))
 			return_0;
@@ -192,7 +192,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 			return_0;
 
 	/* Update internal system_id if we changed it */
-	if (vg &&
+	if (vg && vg->lvm1_system_id &&
 	    (!*vg->lvm1_system_id ||
 	     strncmp(vg->lvm1_system_id, (char *)pvd->system_id, sizeof(pvd->system_id))))
 		    strncpy(vg->lvm1_system_id, (char *)pvd->system_id, NAME_LEN);


