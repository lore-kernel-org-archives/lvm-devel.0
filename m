From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 10 Aug 2009 14:08:22 -0400
Subject: [PATCH 1/4] Split vg_remove_single into 2 functions - the second part commits to disk.
In-Reply-To: <1249927705-28528-1-git-send-email-dwysocha@redhat.com>
References: <1249927705-28528-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1249927705-28528-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Split vg_remove_single into vg_remove_check (mandatory checks before
vgremove) and vg_remove_ondisk (do actual remove by committing to disk).
The choice of the last word in these functions probably can be improved but
greps out ok in the tree.

In liblvm, we'd like to provide an consistent API that allows multiple
changes in memory, then let lvm_vg_write() control the commit to disk.  In
some cases (for example, lvresize calls fsadm) this may not be possible.
However, since we are using an object model and dividing things into small
operations, the most logical model seems to be the lvm_vg_write model, and
handling the special cases as they arrive.  So as best as possible
we move towards this end.

A possible optimization would be to consolidate vg_remove_ondisk
code with vgreduce code.  A second possible optimization is making vgreduce
of the last device equivalent to vgremove.  Today, lvm_vg_reduce fails if
vgreduce is called with the last device, but from an object model perspective,
we could view this as equivalent to vgremove and allow it.  My gut feel is
we do not want to do this though.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    3 ++-
 lib/metadata/metadata.c          |   14 ++++++++++----
 liblvm/lvm_vg.c                  |    5 ++++-
 tools/vgremove.c                 |    5 ++++-
 4 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d8d1a93..c7599a2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -442,7 +442,8 @@ uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove(struct volume_group *vg);
-int vg_remove_single(struct volume_group *vg);
+int vg_remove_check(struct volume_group *vg);
+int vg_remove_ondisk(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9c8af3d..6767668 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -468,12 +468,9 @@ int remove_lvs_in_vg(struct cmd_context *cmd,
 	return 1;
 }
 
-int vg_remove_single(struct volume_group *vg)
+int vg_remove_check(struct volume_group *vg)
 {
-	struct physical_volume *pv;
-	struct pv_list *pvl;
 	unsigned lv_count;
-	int ret = 1;
 
 	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
@@ -497,6 +494,15 @@ int vg_remove_single(struct volume_group *vg)
 	if (!archive(vg))
 		return 0;
 
+	return 1;
+}
+
+int vg_remove_ondisk(struct volume_group *vg)
+{
+	struct physical_volume *pv;
+	struct pv_list *pvl;
+	int ret = 1;
+
 	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return 0;
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 15cc831..a659e27 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -153,7 +153,10 @@ int lvm_vg_remove(vg_t *vg)
 	if (!vg_check_write_mode(vg))
 		return -1;
 
-	if (!vg_remove_single(vg))
+	if (!vg_remove_check(vg))
+		return -1;
+
+	if (!vg_remove_ondisk(vg))
 		return -1;
 	return 0;
 }
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 78804a7..54afe12 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -44,7 +44,10 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 			return ECMD_FAILED;
 	}
 
-	if (!vg_remove_single(vg))
+	if (!vg_remove_check(vg))
+		return ECMD_FAILED;
+
+	if (!vg_remove_ondisk(vg))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;
-- 
1.6.0.6


