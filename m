From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 14 Sep 2009 12:35:03 -0400
Subject: [PATCH 1/2] Add most relevant vg_attr fields as lvm2app 'get' functions.
In-Reply-To: <1252946104-4824-1-git-send-email-dwysocha@redhat.com>
References: <1252946104-4824-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1252946104-4824-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Of the vgs field vg_attr, a few of the most likely to be used attributes
are clustered, exported, and partial.  I thought explicitly stating what
'partial' meant was clearer.  So this patch adds the following 3 functions:
uint64_t lvm_vg_is_clustered(const vg_t vg)
uint64_t lvm_vg_is_exported(const vg_t vg)
uint64_t lvm_vg_is_missing_pvs(const vg_t vg)

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 liblvm/lvm2app.h                 |   33 +++++++++++++++++++++++++++++++++
 liblvm/lvm_vg.c                  |   15 +++++++++++++++
 3 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1393aae..0861f4d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -721,6 +721,7 @@ uint64_t vg_max_pv(const struct volume_group *vg);
 uint64_t vg_max_lv(const struct volume_group *vg);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
+#define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
 
 struct vgcreate_params {
 	char *vg_name;
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index d6b67ce..3bfbf31 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -481,6 +481,39 @@ int lvm_vg_reduce(vg_t vg, const char *device);
 int lvm_vg_set_extent_size(vg_t vg, uint32_t new_size);
 
 /**
+ * Get whether or not a volume group is clustered.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 1 if the VG is clustered, 0 if not
+ */
+uint64_t lvm_vg_is_clustered(vg_t vg);
+
+/**
+ * Get whether or not a volume group is exported.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 1 if the VG is exported, 0 if not
+ */
+uint64_t lvm_vg_is_exported(vg_t vg);
+
+/**
+ * Get whether or not a volume group is missing physical volumes.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 1 if the VG is missing PVs, 0 if not
+ */
+uint64_t lvm_vg_is_missing_pvs(vg_t vg);
+
+/**
  * Get the current metadata sequence number of a volume group.
  *
  * The metadata sequence number is incrented for each metadata change.
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index dcfd722..44b0b97 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -243,6 +243,21 @@ uint64_t lvm_vg_get_seqno(const vg_t vg)
 	return vg_seqno(vg);
 }
 
+uint64_t lvm_vg_is_clustered(const vg_t vg)
+{
+	return vg_is_clustered(vg);
+}
+
+uint64_t lvm_vg_is_exported(const vg_t vg)
+{
+	return vg_is_exported(vg);
+}
+
+uint64_t lvm_vg_is_missing_pvs(const vg_t vg)
+{
+	return (vg_missing_pv_count(vg) != 0);
+}
+
 /* FIXME: invalid handle? return INTMAX? */
 uint64_t lvm_vg_get_size(const vg_t vg)
 {
-- 
1.6.0.6


