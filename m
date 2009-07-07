From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  7 Jul 2009 03:50:04 -0400
Subject: [PATCH 3/7] Rename vg_change_pesize to vg_set_extent_size and use vg_t.
In-Reply-To: <1246953008-27609-3-git-send-email-dwysocha@redhat.com>
References: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-2-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1246953008-27609-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Rename vg_change_pesize to vg_set_extent_size and use vg_t.
In liblvm, we will reserve the word 'change' to mean an API that
both sets one or more values, and commits to disk.  This will be
consistent with the LVM commandline.  The existing vg_change_pesize()
function does not commit to disk, but just changes the extent_size
and ensures all internal structures are updated.  This logic should
be contained in a function that sets the value.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |    2 +-
 tools/vgchange.c                 |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b103518..70c24dd 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -440,7 +440,7 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
-int vg_change_pesize(struct volume_group *vg, uint32_t new_extent_size);
+int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b0c83cc..2237f83 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -624,7 +624,7 @@ static int _recalc_extents(uint32_t *extents, const char *desc1,
 	return 1;
 }
 
-int vg_change_pesize(struct volume_group *vg, uint32_t new_size)
+int vg_set_extent_size(vg_t *vg, uint32_t new_size)
 {
 	uint32_t old_size = vg->extent_size;
 	struct pv_list *pvl;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index ade0735..a2b8aa9 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -397,7 +397,7 @@ static int _vgchange_pesize(struct cmd_context *cmd, struct volume_group *vg)
 	if (!archive(vg))
 		return ECMD_FAILED;
 
-	if (!vg_change_pesize(vg, extent_size)) {
+	if (!vg_set_extent_size(vg, extent_size)) {
 		stack;
 		return EINVALID_CMD_LINE;
 	}
-- 
1.6.0.6


