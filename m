From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  4 Aug 2015 08:35:43 +0000 (UTC)
Subject: master - coverity: check vg->lvm1_system_id is not NULL before calling strncmp with that
Message-ID: <20150804083543.AA711601D2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f02cdcff0084a323c9651d7ca2f22d60c83bcf3d
Commit:        f02cdcff0084a323c9651d7ca2f22d60c83bcf3d
Parent:        1f3d04cddf5a447de9bfb81ed22d0ccbe58e82fc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 4 10:16:45 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 4 10:35:31 2015 +0200

coverity: check vg->lvm1_system_id is not NULL before calling strncmp with that

lib/format1/import-export.c:167: var_deref_model: Passing null pointer "vg->lvm1_system_id" to "strncmp", which dereferences it.
---
 lib/format1/import-export.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 275583d..9e49a96 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -164,7 +164,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 	/* Is VG already exported or being exported? */
 	if (vg && vg_is_exported(vg)) {
 		/* Does system_id need setting? */
-		if ((vg->lvm1_system_id && !*vg->lvm1_system_id) ||
+		if (!vg->lvm1_system_id || !*vg->lvm1_system_id ||
 		    strncmp(vg->lvm1_system_id, EXPORTED_TAG,
 			    sizeof(EXPORTED_TAG) - 1)) {
 			if (!generate_lvm1_system_id(cmd, (char *)pvd->system_id, EXPORTED_TAG))


