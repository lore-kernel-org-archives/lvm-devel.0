From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 20 May 2015 17:48:16 +0000 (UTC)
Subject: master - format_text: Parse (optional) outdated_pvs section in VG metadata.
Message-ID: <20150520174816.175EB60188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=43224f22e460eddd3d4ee993d4585b4c8f421357
Commit:        43224f22e460eddd3d4ee993d4585b4c8f421357
Parent:        e8d00e068762d0ebd7dd489d45c43927b7ffdc58
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 29 15:02:26 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed May 20 19:46:14 2015 +0200

format_text: Parse (optional) outdated_pvs section in VG metadata.

---
 lib/format_text/import_vsn1.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 3030bad..2d62905 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -167,6 +167,8 @@ static int _read_pv(struct format_instance *fid,
 	const struct dm_config_value *cv;
 	uint64_t size, ba_start;
 
+	int outdated = !strcmp(pvn->parent->key, "outdated_pvs");
+
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
 	    !(pvl->pv = dm_pool_zalloc(mem, sizeof(*pvl->pv))))
 		return_0;
@@ -212,7 +214,7 @@ static int _read_pv(struct format_instance *fid,
 
 	memcpy(&pv->vgid, &vg->id, sizeof(vg->id));
 
-	if (!_read_flag_config(pvn, &pv->status, PV_FLAGS)) {
+	if (!outdated && !_read_flag_config(pvn, &pv->status, PV_FLAGS)) {
 		log_error("Couldn't read status flags for physical volume.");
 		return 0;
 	}
@@ -234,13 +236,13 @@ static int _read_pv(struct format_instance *fid,
 		return 0;
 	}
 
-	if (!_read_uint64(pvn, "pe_start", &pv->pe_start)) {
+	if (!outdated && !_read_uint64(pvn, "pe_start", &pv->pe_start)) {
 		log_error("Couldn't read extent start value (pe_start) "
 			  "for physical volume.");
 		return 0;
 	}
 
-	if (!_read_int32(pvn, "pe_count", &pv->pe_count)) {
+	if (!outdated && !_read_int32(pvn, "pe_count", &pv->pe_count)) {
 		log_error("Couldn't find extent count (pe_count) for "
 			  "physical volume.");
 		return 0;
@@ -299,7 +301,10 @@ static int _read_pv(struct format_instance *fid,
 
 	vg->extent_count += pv->pe_count;
 	vg->free_count += pv->pe_count;
-	add_pvl_to_vgs(vg, pvl);
+	if (outdated)
+		dm_list_add(&vg->pvs_outdated, &pvl->list);
+	else
+		add_pvl_to_vgs(vg, pvl);
 
 	return 1;
 }
@@ -877,6 +882,9 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
+	_read_sections(fid, "outdated_pvs", _read_pv, vg,
+		       vgn, pv_hash, lv_hash, 1, &scan_done_once);
+
 	/* Optional tags */
 	if (dm_config_get_list(vgn, "tags", &cv) &&
 	    !(read_tags(vg->vgmem, &vg->tags, cv))) {


