From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Feb 2018 16:20:45 -0500
Subject: master - lvmlockd: improve dm path creation for sanlock LV
Message-ID: <201802122120.w1CLKj6i023721@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4f278324c76c339b59f4c613303573bc64a16272
Commit:        4f278324c76c339b59f4c613303573bc64a16272
Parent:        7239a45b79a6076c198e0542161146257114f5be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 12 21:50:57 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 12 22:14:25 2018 +0100

lvmlockd: improve dm path creation for sanlock LV

Use devmapper function to create matching dm name with mangling.
Drop extra '-1' from buffer passed to snprintf.
---
 daemons/lvmlockd/lvmlockd-sanlock.c |   43 ++++++++++++++++++++++++++++++----
 1 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 795362a..dd88d24 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -294,6 +294,36 @@ out:
 	return host_id;
 }
 
+/* Prepare valid /dev/mapper/vgname-lvname with all the mangling */
+static int build_dm_path(char *path, size_t path_len,
+			 const char *vg_name, const char *lv_name)
+{
+	struct dm_pool *mem;
+	char *dm_name;
+	int rv = 0;
+
+	if (!(mem = dm_pool_create("namepool", 1024))) {
+		log_error("Failed to create mempool.");
+		return -ENOMEM;
+	}
+
+	if (!(dm_name = dm_build_dm_name(mem, vg_name, lv_name, NULL))) {
+		log_error("Failed to build dm name for %s/%s.", vg_name, lv_name);
+		rv = -EINVAL;
+		goto fail;
+	}
+
+	if ((dm_snprintf(path, path_len, "%s/%s", dm_dir(), dm_name) < 0)) {
+		log_error("Failed to create path %s/%s.", dm_dir(), dm_name);
+		rv = -EINVAL;
+	}
+
+fail:
+	dm_pool_destroy(mem);
+
+	return rv;
+}
+
 /*
  * vgcreate
  *
@@ -336,7 +366,8 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	if (strlen(lock_lv_name) + strlen(lock_args_version) + 2 > MAX_ARGS)
 		return -EARGS;
 
-	snprintf(disk.path, SANLK_PATH_LEN-1, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
+	if ((rv = build_dm_path(disk.path, SANLK_PATH_LEN, vg_name, lock_lv_name)))
+		return rv;
 
 	log_debug("S %s init_vg_san path %s", ls_name, disk.path);
 
@@ -513,7 +544,8 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 
 	strncpy(rd.rs.lockspace_name, ls_name, SANLK_NAME_LEN);
 	rd.rs.num_disks = 1;
-	snprintf(rd.rs.disks[0].path, SANLK_PATH_LEN-1, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
+	if ((rv = build_dm_path(rd.rs.disks[0].path, SANLK_PATH_LEN, vg_name, lock_lv_name)))
+		return rv;
 
 	align_size = sanlock_align(&rd.rs.disks[0]);
 	if (align_size <= 0) {
@@ -612,7 +644,8 @@ int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_
 		return rv;
 	}
 
-	snprintf(disk.path, SANLK_PATH_LEN-1, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
+	if ((rv = build_dm_path(disk.path, SANLK_PATH_LEN, vg_name, lock_lv_name)))
+		return rv;
 
 	log_debug("S %s rename_vg_san path %s", ls_name, disk.path);
 
@@ -1088,8 +1121,8 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 		goto fail;
 	}
 
-	snprintf(disk_path, SANLK_PATH_LEN-1, "/dev/mapper/%s-%s",
-		 ls->vg_name, lock_lv_name);
+	if ((rv = build_dm_path(disk_path, SANLK_PATH_LEN, ls->vg_name, lock_lv_name)))
+		goto fail;
 
 	/*
 	 * When a vg is started, the internal sanlock lv should be


