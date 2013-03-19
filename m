From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Mar 2013 14:29:03 +0000 (UTC)
Subject: master - cleanup: remove superfluous wrappers
Message-ID: <20130319142903.6867DA1CC4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b6bab2e30f9f3f8f447e33c19590533c8c92123
Commit:        5b6bab2e30f9f3f8f447e33c19590533c8c92123
Parent:        562ad293fd52b8f3096b28bcac20e32aa1e8c1b0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 19 13:58:02 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 19 13:58:02 2013 +0100

cleanup: remove superfluous wrappers

_find_pv_by_name -> find_pv_by_name
_find_pv_in_vg -> find_pv_in_vg
_find_pv_in_vg_by_uuid -> find_pv_in_vg_by_uuid

The only callers of the underscored variants were their wrappers
without the underscore. No other part of the code referenced the
underscored variants.
---
 lib/metadata/metadata.c |   48 +++++++++-------------------------------------
 1 files changed, 10 insertions(+), 38 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 403d86d..7c2846c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -40,15 +40,6 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct format_instance *fid,
 					int warnings, int scan_label_only);
 
-static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
-			 			const char *pv_name);
-
-static struct pv_list *_find_pv_in_vg(const struct volume_group *vg,
-				      const char *pv_name);
-
-static struct pv_list *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
-					      const struct id *id);
-
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 				    uint64_t status);
 
@@ -244,8 +235,8 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		return 0;
 	}
 
-	if (_find_pv_in_vg(vg, pv_name) ||
-	    _find_pv_in_vg_by_uuid(vg, &pv->id)) {
+	if (find_pv_in_vg(vg, pv_name) ||
+	    find_pv_in_vg_by_uuid(vg, &pv->id)) {
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
 			stack;
 			uuid[0] = '\0';
@@ -1690,13 +1681,7 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 
 /* FIXME: liblvm todo - make into function that returns handle */
 struct pv_list *find_pv_in_vg(const struct volume_group *vg,
-			      const char *pv_name)
-{
-	return _find_pv_in_vg(vg, pv_name);
-}
-
-static struct pv_list *_find_pv_in_vg(const struct volume_group *vg,
-				      const char *pv_name)
+			       const char *pv_name)
 {
 	struct pv_list *pvl;
 
@@ -1730,18 +1715,6 @@ int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv)
 	return 0;
 }
 
-static struct pv_list *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
-					      const struct id *id)
-{
-	struct pv_list *pvl;
-
-	dm_list_iterate_items(pvl, &vg->pvs)
-		if (id_equal(&pvl->pv->id, id))
-			return pvl;
-
-	return NULL;
-}
-
 /**
  * find_pv_in_vg_by_uuid - Find PV in VG by PV UUID
  * @vg: volume group to search
@@ -1757,7 +1730,13 @@ static struct pv_list *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
 struct pv_list *find_pv_in_vg_by_uuid(const struct volume_group *vg,
 				      const struct id *id)
 {
-	return _find_pv_in_vg_by_uuid(vg, id);
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, &vg->pvs)
+		if (id_equal(&pvl->pv->id, id))
+			return pvl;
+
+	return NULL;
 }
 
 struct lv_list *find_lv_in_vg(const struct volume_group *vg,
@@ -1825,13 +1804,6 @@ struct physical_volume *find_pv(struct volume_group *vg, struct device *dev)
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 					const char *pv_name)
 {
-	return _find_pv_by_name(cmd, pv_name);
-}
-
-
-static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
-			 			const char *pv_name)
-{
 	struct physical_volume *pv;
 
 	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, 1, 0))) {


