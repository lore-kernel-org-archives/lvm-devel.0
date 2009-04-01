From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 01 Apr 2009 17:13:39 -0400
Subject: [PATCH] save and restore the previous logging level
Message-ID: <49D3D903.20006@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This is a patch to save and restore the previous log suppress
level to handle nested calls correctly.

Regards,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/format_text/archiver.c    |    7 ++++---
 lib/format_text/import_vsn1.c |    5 +++--
 lib/snapshot/snapshot.c       |    9 +++++----
 3 files changed, 12 insertions(+), 9 deletions(-)

Index: LVM2.02.46-20090401/lib/format_text/archiver.c
===================================================================
--- LVM2.02.46-20090401.orig/lib/format_text/archiver.c
+++ LVM2.02.46-20090401/lib/format_text/archiver.c
@@ -397,6 +397,7 @@ void check_current_backup(struct volume_
 {
 	char path[PATH_MAX];
 	struct volume_group *vg_backup;
+	int old_suppress;
 
 	if (vg->status & EXPORTED_VG)
 		return;
@@ -407,15 +408,15 @@ void check_current_backup(struct volume_
 		return;
 	}
 
-	log_suppress(1);
+	old_suppress = log_suppress(1);
 	/* Up-to-date backup exists? */
 	if ((vg_backup = backup_read_vg(vg->cmd, vg->name, path)) &&
 	    (vg->seqno == vg_backup->seqno) &&
 	    (id_equal(&vg->id, &vg_backup->id))) {
-		log_suppress(0);
+		log_suppress(old_suppress);
 		return;
 	}
-	log_suppress(0);
+	log_suppress(old_suppress);
 
 	if (vg_backup)
 		archive(vg_backup);
Index: LVM2.02.46-20090401/lib/format_text/import_vsn1.c
===================================================================
--- LVM2.02.46-20090401.orig/lib/format_text/import_vsn1.c
+++ LVM2.02.46-20090401/lib/format_text/import_vsn1.c
@@ -816,10 +816,11 @@ static void _read_desc(struct dm_pool *m
 {
 	const char *d;
 	unsigned int u = 0u;
+	int old_suppress;
 
-	log_suppress(1);
+	old_suppress = log_suppress(1);
 	d = find_config_str(cft->root, "description", "");
-	log_suppress(0);
+	log_suppress(old_suppress);
 	*desc = dm_pool_strdup(mem, d);
 
 	get_config_uint32(cft->root, "creation_time", &u);
Index: LVM2.02.46-20090401/lib/snapshot/snapshot.c
===================================================================
--- LVM2.02.46-20090401.orig/lib/snapshot/snapshot.c
+++ LVM2.02.46-20090401/lib/snapshot/snapshot.c
@@ -37,6 +37,7 @@ static int _snap_text_import(struct lv_s
 	uint32_t chunk_size;
 	const char *org_name, *cow_name;
 	struct logical_volume *org, *cow;
+	int old_suppress;
 
 	seg->lv->status |= SNAPSHOT;
 
@@ -45,21 +46,21 @@ static int _snap_text_import(struct lv_s
 		return 0;
 	}
 
-	log_suppress(1);
+	old_suppress = log_suppress(1);
 
 	if (!(cow_name = find_config_str(sn, "cow_store", NULL))) {
-		log_suppress(0);
+		log_suppress(old_suppress);
 		log_error("Snapshot cow storage not specified.");
 		return 0;
 	}
 
 	if (!(org_name = find_config_str(sn, "origin", NULL))) {
-		log_suppress(0);
+		log_suppress(old_suppress);
 		log_error("Snapshot origin not specified.");
 		return 0;
 	}
 
-	log_suppress(0);
+	log_suppress(old_suppress);
 
 	if (!(cow = find_lv(seg->lv->vg, cow_name))) {
 		log_error("Unknown logical volume specified for "


