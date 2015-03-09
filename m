From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  9 Mar 2015 19:35:01 +0000 (UTC)
Subject: master - format_text: Set system id directly.
Message-ID: <20150309193501.9C08660366@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d3711c0b2a1679b18e0ee3032c5d38149a6619b
Commit:        1d3711c0b2a1679b18e0ee3032c5d38149a6619b
Parent:        379d9ec8ec1a07b8fd218ab155ed7f6e611d8c73
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Mar 9 19:33:27 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Mar 9 19:33:27 2015 +0000

format_text: Set system id directly.

Rearrange _read_vg code to set the appropriate system id field directly.
---
 lib/format_text/import_vsn1.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index f930c08..1569aaa 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -739,11 +739,10 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 {
 	const struct dm_config_node *vgn;
 	const struct dm_config_value *cv;
-	const char *str, *format_str;
+	const char *str, *format_str, *system_id;
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL, *lv_hash = NULL;
 	unsigned scan_done_once = use_cached_pvs;
-	char *system_id;
 	uint64_t vgstatus;
 
 	/* skip any top-level values */
@@ -758,10 +757,6 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	if (!(vg = alloc_vg("read_vg", fid->fmt->cmd, vgn->key)))
 		return_NULL;
 
-	if (!(system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
-		goto_bad;
-	vg->system_id = system_id;
-
 	/*
 	 * The pv hash memorises the pv section names -> pv
 	 * structures.
@@ -789,9 +784,6 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	if (dm_config_get_str(vgn, "system_id", &str))
-		strncpy(system_id, str, NAME_LEN);
-
 	if (dm_config_get_str(vgn, "lock_type", &str)) {
 		if (!(vg->lock_type = dm_pool_strdup(vg->vgmem, str)))
 			goto bad;
@@ -817,9 +809,15 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	/*
 	 * A system id without WRITE_LOCKED is an old lvm1 system id.
 	 */
-	if (!(vgstatus & LVM_WRITE_LOCKED) && system_id[0]) {
-		memcpy(vg->lvm1_system_id, system_id, NAME_LEN + 1);
-		memset(system_id, 0, NAME_LEN + 1);
+	if (dm_config_get_str(vgn, "system_id", &system_id)) {
+		if (!(vgstatus & LVM_WRITE_LOCKED)) {
+			if (!(vg->lvm1_system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
+				goto_bad;
+			strncpy(vg->lvm1_system_id, system_id, NAME_LEN);
+		} else if (!(vg->system_id = dm_pool_strdup(vg->vgmem, system_id))) {
+			log_error("Failed to allocate memory for system_id in _read_vg.");
+			goto bad;
+		}
 	}
 
 	if (vgstatus & LVM_WRITE_LOCKED) {


