From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  9 Mar 2015 19:34:59 +0000 (UTC)
Subject: master - systemid: Use temp status var for LVM_WRITE_LOCKED
Message-ID: <20150309193459.7CF5E60366@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=379d9ec8ec1a07b8fd218ab155ed7f6e611d8c73
Commit:        379d9ec8ec1a07b8fd218ab155ed7f6e611d8c73
Parent:        458b0210d1b4195171992f112aeb3a798d4509a3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Mar 9 19:18:14 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Mar 9 19:18:14 2015 +0000

systemid: Use temp status var for LVM_WRITE_LOCKED

---
 lib/format_text/import_vsn1.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 837af6b..f930c08 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -531,7 +531,7 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	const char *str;
 	const struct dm_config_value *cv;
 	const char *hostname;
-	uint64_t timestamp = 0;
+	uint64_t timestamp = 0, lvstatus;
 
 	if (!(lv = alloc_lv(mem)))
 		return_0;
@@ -544,16 +544,17 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 		return 0;
 	}
 
-	if (!_read_flag_config(lvn, &lv->status, LV_FLAGS)) {
+	if (!_read_flag_config(lvn, &lvstatus, LV_FLAGS)) {
 		log_error("Couldn't read status flags for logical volume %s.",
 			  lv->name);
 		return 0;
 	}
 
-	if (lv->status & LVM_WRITE_LOCKED) {
-		lv->status |= LVM_WRITE;
-		lv->status &= ~LVM_WRITE_LOCKED;
+	if (lvstatus & LVM_WRITE_LOCKED) {
+		lvstatus |= LVM_WRITE;
+		lvstatus &= ~LVM_WRITE_LOCKED;
 	}
+	lv->status = lvstatus;
 
 	if (dm_config_has_node(lvn, "creation_time")) {
 		if (!_read_uint64(lvn, "creation_time", &timestamp)) {
@@ -743,6 +744,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	struct dm_hash_table *pv_hash = NULL, *lv_hash = NULL;
 	unsigned scan_done_once = use_cached_pvs;
 	char *system_id;
+	uint64_t vgstatus;
 
 	/* skip any top-level values */
 	for (vgn = cft->root; (vgn && vgn->v); vgn = vgn->sib)
@@ -806,7 +808,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	if (!_read_flag_config(vgn, &vg->status, VG_FLAGS)) {
+	if (!_read_flag_config(vgn, &vgstatus, VG_FLAGS)) {
 		log_error("Error reading flags of volume group %s.",
 			  vg->name);
 		goto bad;
@@ -815,15 +817,16 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	/*
 	 * A system id without WRITE_LOCKED is an old lvm1 system id.
 	 */
-	if (!(vg->status & LVM_WRITE_LOCKED) && system_id[0]) {
+	if (!(vgstatus & LVM_WRITE_LOCKED) && system_id[0]) {
 		memcpy(vg->lvm1_system_id, system_id, NAME_LEN + 1);
 		memset(system_id, 0, NAME_LEN + 1);
 	}
 
-	if (vg->status & LVM_WRITE_LOCKED) {
-		vg->status |= LVM_WRITE;
-		vg->status &= ~LVM_WRITE_LOCKED;
+	if (vgstatus & LVM_WRITE_LOCKED) {
+		vgstatus |= LVM_WRITE;
+		vgstatus &= ~LVM_WRITE_LOCKED;
 	}
+	vg->status = vgstatus;
 
 	if (!_read_int32(vgn, "extent_size", &vg->extent_size)) {
 		log_error("Couldn't read extent size for volume group %s.",


