From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 10 Aug 2009 14:08:25 -0400
Subject: [PATCH 4/4] Rename internal library function vg_remove to vg_remove_mdas.
In-Reply-To: <1249927705-28528-4-git-send-email-dwysocha@redhat.com>
References: <1249927705-28528-1-git-send-email-dwysocha@redhat.com>
	<1249927705-28528-2-git-send-email-dwysocha@redhat.com>
	<1249927705-28528-3-git-send-email-dwysocha@redhat.com>
	<1249927705-28528-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1249927705-28528-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Later patches should consolidate the vgremove / vgreduce functions but for
now let's clarify what vg_remove actually does by changing the name.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    6 +++---
 lib/metadata/metadata.c          |    6 +++---
 tools/vgconvert.c                |    2 +-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c7599a2..1004808 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1,6 +1,6 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -441,7 +441,7 @@ int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
-int vg_remove(struct volume_group *vg);
+int vg_remove_mdas(struct volume_group *vg);
 int vg_remove_check(struct volume_group *vg);
 int vg_remove_ondisk(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0f53832..3eb570f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -513,8 +513,8 @@ int vg_remove_ondisk(struct volume_group *vg)
 		return 0;
 	}
 
-	if (!vg_remove(vg)) {
-		log_error("vg_remove %s failed", vg->name);
+	if (!vg_remove_mdas(vg)) {
+		log_error("vg_remove_mdas %s failed", vg->name);
 		unlock_vg(vg->cmd, VG_ORPHANS);
 		return 0;
 	}
@@ -1683,7 +1683,7 @@ struct pv_segment *find_peg_by_pe(const struct physical_volume *pv, uint32_t pe)
 	return NULL;
 }
 
-int vg_remove(struct volume_group *vg)
+int vg_remove_mdas(struct volume_group *vg)
 {
 	struct metadata_area *mda;
 
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index a8b064d..d24b010 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -167,7 +167,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	log_verbose("Deleting existing metadata for VG %s", vg_name);
-	if (!vg_remove(vg)) {
+	if (!vg_remove_mdas(vg)) {
 		log_error("Removal of existing metadata for %s failed.",
 			  vg_name);
 		log_error("Use pvcreate and vgcfgrestore to repair "
-- 
1.6.0.6


