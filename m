From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 28 Jul 2009 11:03:13 -0400
Subject: [PATCH] Add an open_mode to the vg struct for liblvm - enforce read / write semantics.
Message-ID: <1248793393-4493-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For now, a simple way to enforce the read/write semantics is to just save the
open mode of the VG.  If the caller uses lvm_vg_create, the mode is write.
The caller using lvm_vg_open can use either read or write to open the VG.
Once we have this, we enforce the permissions on each API call and don't allow
a caller to modify a VG that has not been opened properly.

This may be better combined with the locking mode, but I view that as future
cleanup, past this initial release.  The intial release should enforce the
basic object semantics though, as described in the lvm.h file.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/metadata.c          |   10 ++++++++++
 liblvm/lvm_lv.c                  |    5 ++++-
 liblvm/lvm_vg.c                  |   14 ++++++++++++++
 4 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0ed48e3..bd207da 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -247,6 +247,7 @@ struct volume_group {
 	 * They have to get cleared on vg_commit.
 	 */
 	struct dm_list removed_pvs;
+	uint32_t open_mode; /* FIXME: read or write - check lock type? */
 
 	/*
 	 * Store result of the last vg_read().
@@ -713,6 +714,7 @@ uint64_t vg_extent_size(const vg_t *vg);
 uint64_t vg_extent_count(const vg_t *vg);
 uint64_t vg_free_count(const vg_t *vg);
 uint64_t vg_pv_count(const vg_t *vg);
+int vg_check_write_mode(vg_t *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 
 struct vgcreate_params {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d25ad68..75e4495 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3042,6 +3042,16 @@ int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 	return 1;
 }
 
+/* FIXME: remove / combine this with locking? */
+int vg_check_write_mode(vg_t *vg)
+{
+	if (vg->open_mode != 'w') {
+		log_errno(EPERM, "Attempt to modify a read-only VG\n");
+		return 0;
+	}
+	return 1;
+}
+
 /*
  * Performs a set of checks against a VG according to bits set in status
  * and returns FAILED_* bits for those that aren't acceptable.
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 188b9b4..46b0360 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -107,9 +107,10 @@ lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size)
 	uint64_t extents;
 	struct lv_list *lvl;
 
-	/* FIXME: check for proper VG access */
 	if (vg_read_error(vg))
 		return NULL;
+	if (!vg_check_write_mode(vg))
+		return NULL;
 	memset(&lp, 0, sizeof(lp));
 	extents = extents_from_size(vg->cmd, size, vg->extent_size);
 	_lv_set_default_params(&lp, vg, name, extents);
@@ -130,6 +131,8 @@ int lvm_vg_remove_lv(lv_t *lv)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg))
 		return -1;
+	if (!vg_check_write_mode(lv->vg))
+		return -1;
 	if (!lv_remove_single(lv->vg->cmd, lv, DONT_PROMPT))
 		return -1;
 	return 0;
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index bd04d81..048cae9 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -35,6 +35,7 @@ vg_t *lvm_vg_create(lvm_t libh, const char *vg_name)
 		vg_release(vg);
 		return NULL;
 	}
+	vg->open_mode = 'w';
 	return vg;
 }
 
@@ -43,6 +44,9 @@ int lvm_vg_extend(vg_t *vg, const char *device)
 	if (vg_read_error(vg))
 		return -1;
 
+	if (!vg_check_write_mode(vg))
+		return -1;
+
 	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return -1;
@@ -72,6 +76,8 @@ int lvm_vg_reduce(vg_t *vg, const char *device)
 {
 	if (vg_read_error(vg))
 		return -1;
+	if (!vg_check_write_mode(vg))
+		return -1;
 
 	if (!vg_reduce(vg, (char *)device))
 		return -1;
@@ -82,6 +88,8 @@ int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size)
 {
 	if (vg_read_error(vg))
 		return -1;
+	if (!vg_check_write_mode(vg))
+		return -1;
 
 	if (!vg_set_extent_size(vg, new_size))
 		return -1;
@@ -94,6 +102,8 @@ int lvm_vg_write(vg_t *vg)
 
 	if (vg_read_error(vg))
 		return -1;
+	if (!vg_check_write_mode(vg))
+		return -1;
 
 	if (dm_list_empty(&vg->pvs)) {
 		log_error("Volume group %s does not contain any "
@@ -140,6 +150,8 @@ int lvm_vg_remove(vg_t *vg)
 {
 	if (vg_read_error(vg))
 		return -1;
+	if (!vg_check_write_mode(vg))
+		return -1;
 
 	if (!vg_remove_single(vg))
 		return -1;
@@ -165,6 +177,8 @@ vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 		vg_release(vg);
 		return NULL;
 	}
+	/* FIXME: combine this with locking ? */
+	vg->open_mode = mode[0];
 
 	return vg;
 }
-- 
1.6.0.6


