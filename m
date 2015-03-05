From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  5 Mar 2015 15:49:59 +0000 (UTC)
Subject: master - Revert "systemid: Add ACCESS_NEEDS_SYSTEM_ID VG flag."
Message-ID: <20150305154959.2F7CE610F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6a57dc4f3af6aa8912fc1f969937e3e3c47f725
Commit:        c6a57dc4f3af6aa8912fc1f969937e3e3c47f725
Parent:        06b408ecce9d95f768ace998b83674140bc05abc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 4 11:11:10 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 5 09:50:43 2015 -0600

Revert "systemid: Add ACCESS_NEEDS_SYSTEM_ID VG flag."

This reverts commit bfbb5d269aa1ed56d9308117b57d4d2da49d53f6.

This will be done differently.
---
 lib/format1/format1.c            |    2 --
 lib/format1/import-export.c      |    4 +---
 lib/format_text/flags.c          |    1 -
 lib/format_text/import_vsn1.c    |   20 ++++++++------------
 lib/metadata/metadata-exported.h |    3 +--
 lib/metadata/vg.c                |    3 ---
 tools/vgchange.c                 |    6 +-----
 7 files changed, 11 insertions(+), 28 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 7f37cf5..19df8aa 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -501,8 +501,6 @@ static int _format1_vg_setup(struct format_instance *fid, struct volume_group *v
             !generate_lvm1_system_id(vg->cmd, vg->lvm1_system_id, ""))
 		return_0;
 
-	vg->status &= ~ACCESS_NEEDS_SYSTEM_ID;
-
 	return 1;
 }
 
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 4846a8b..9b387e2 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -69,10 +69,8 @@ int import_pv(const struct format_type *fmt, struct dm_pool *mem,
 	memcpy(&pv->vgid, vgd->vg_uuid, sizeof(vg->id));
 
 	/* Store system_id from first PV if PV belongs to a VG */
-	if (vg && !*vg->lvm1_system_id) {
+	if (vg && !*vg->lvm1_system_id)
 		strncpy(vg->lvm1_system_id, (char *)pvd->system_id, NAME_LEN);
-		vg->status &= ~ACCESS_NEEDS_SYSTEM_ID;
-	}
 
 	if (vg &&
 	    strncmp(vg->lvm1_system_id, (char *)pvd->system_id, sizeof(pvd->system_id)))
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 1a4a503..cf01271 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -36,7 +36,6 @@ static const struct flag _vg_flags[] = {
 	{LVM_WRITE, "WRITE", STATUS_FLAG},
 	{CLUSTERED, "CLUSTERED", STATUS_FLAG},
 	{SHARED, "SHARED", STATUS_FLAG},
-	{ACCESS_NEEDS_SYSTEM_ID, "ACCESS_NEEDS_SYSTEM_ID", STATUS_FLAG},
 	{PARTIAL_VG, NULL, 0},
 	{PRECOMMITTED, NULL, 0},
 	{ARCHIVED_VG, NULL, 0},
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 8ab9363e..64c08a0 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -733,10 +733,11 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 {
 	const struct dm_config_node *vgn;
 	const struct dm_config_value *cv;
-	const char *str, *system_id, *format_str;
+	const char *str, *format_str;
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL, *lv_hash = NULL;
 	unsigned scan_done_once = use_cached_pvs;
+	char *system_id;
 
 	/* skip any top-level values */
 	for (vgn = cft->root; (vgn && vgn->v); vgn = vgn->sib)
@@ -750,6 +751,9 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	if (!(vg = alloc_vg("read_vg", fid->fmt->cmd, vgn->key)))
 		return_NULL;
 
+	if (!(system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
+		goto_bad;
+	vg->system_id = system_id;
 
 	/*
 	 * The pv hash memorises the pv section names -> pv
@@ -778,6 +782,9 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
+	if (dm_config_get_str(vgn, "system_id", &str))
+		strncpy(system_id, str, NAME_LEN);
+
 	if (!_read_id(&vg->id, vgn, "id")) {
 		log_error("Couldn't read uuid for volume group %s.", vg->name);
 		goto bad;
@@ -795,17 +802,6 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	if (dm_config_get_str(vgn, "system_id", &system_id)) {
-		if (!(vg->status & ACCESS_NEEDS_SYSTEM_ID)) {
-			if (!(vg->lvm1_system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
-				goto_bad;
-			strncpy(vg->lvm1_system_id, system_id, NAME_LEN);
-		} else if (!(vg->system_id = dm_pool_strdup(vg->vgmem, system_id))) {
-			log_error("Failed to allocate memory for system_id in vg_set_system_id.");
-			goto bad;
-		}
-	}
-
 	if (!_read_int32(vgn, "extent_size", &vg->extent_size)) {
 		log_error("Couldn't read extent size for volume group %s.",
 			  vg->name);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5fbfdef..758fa53 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -60,7 +60,6 @@
 #define LVM_WRITE		UINT64_C(0x0000000000000200)	/* LV, VG */
 
 #define CLUSTERED		UINT64_C(0x0000000000000400)	/* VG */
-#define ACCESS_NEEDS_SYSTEM_ID	UINT64_C(0x0020000000000000)    /* VG */
 //#define SHARED		UINT64_C(0x0000000000000800)	/* VG */
 
 /* FIXME Remove when metadata restructuring is completed */
@@ -123,7 +122,7 @@
 #define PV_ALLOCATION_PROHIBITED	UINT64_C(0x0010000000000000)	/* PV - internal use only - allocation prohibited
 									e.g. to prohibit allocation of a RAID image
 									on a PV already holing an image of the RAID set */
-/* Next unused flag:		UINT64_C(0x0040000000000000)    */
+/* Next unused flag:		UINT64_C(0x0020000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index b23063e..404cc6f 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -615,7 +615,6 @@ int vg_set_system_id(struct volume_group *vg, const char *system_id)
 {
 	if (!system_id || !*system_id) {
 		vg->system_id = NULL;
-		vg->status &= ~ACCESS_NEEDS_SYSTEM_ID;
 		return 1;
 	}
 
@@ -633,8 +632,6 @@ int vg_set_system_id(struct volume_group *vg, const char *system_id)
 	if (vg->lvm1_system_id)
 		*vg->lvm1_system_id = '\0';
 
-	vg->status |= ACCESS_NEEDS_SYSTEM_ID;
-
 	return 1;
 }
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 557fe34..36b44a9 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -575,14 +575,10 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 		    vg->name, vg->system_id, system_id);
 
 	vg->system_id = system_id;
+	
 	if (vg->lvm1_system_id)
 		*vg->lvm1_system_id = '\0';
 
-	if (vg->system_id && *vg->system_id)
-		vg->status |= ACCESS_NEEDS_SYSTEM_ID;
-	else
-		vg->status &= ~ACCESS_NEEDS_SYSTEM_ID;
-
 	return 1;
 }
 


