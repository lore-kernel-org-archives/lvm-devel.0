From: Thomas Woerner <twoerner@redhat.com>
Date: Mon, 27 Jul 2009 15:12:36 +0200
Subject: [PATCH 2/3] Add lvm_vg_reduce to liblvm2app
In-Reply-To: <1248700357-10112-2-git-send-email-twoerner@redhat.com>
References: <1248700357-10112-1-git-send-email-twoerner@redhat.com>
	<1248700357-10112-2-git-send-email-twoerner@redhat.com>
Message-ID: <1248700357-10112-3-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Extend lvm_vg_write to remove pvs removed in lvm_vg_reduce. The lvm
volume_group internal structure removed_pvs is used for that. The list is
empty afterwards.

Add new test for vg->pvs emptyness to lvm_vg_write to prevent to write empty
vgs. This is needed cbecause of lvm_vg_reduce and lv_vg_create, which creates
empty vgs.

Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 liblvm/.exported_symbols |    1 +
 liblvm/lvm.h             |   18 +++++++
 liblvm/lvm_vg.c          |   25 ++++++++++
 test/api/vgtest.c        |  118 +++++++++++++++++++++++++++++-----------------
 4 files changed, 119 insertions(+), 43 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index 9911423..68edb87 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -21,6 +21,7 @@ lvm_lv_is_active
 lvm_lv_is_suspended
 lvm_vg_create
 lvm_vg_extend
+lvm_vg_reduce
 lvm_vg_set_extent_size
 lvm_vg_write
 lvm_vg_open
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index 328b33e..92e946c 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -319,6 +319,24 @@ int lvm_vg_close(vg_t *vg);
 int lvm_vg_extend(vg_t *vg, const char *device);
 
 /**
+ * Reduce a VG by removeing an unused device.
+ *
+ * This API requires calling lvm_vg_write to commit the change to disk.
+ * After successfully removing a device, use lvm_vg_write to commit the new VG
+ * to disk.  Upon failure, retry the operation or release the VG handle with
+ * lvm_vg_close.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create.
+ *
+ * \param   device
+ *          Name of device to remove from VG.
+ *
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_reduce(vg_t *vg, const char *device);
+
+/**
  * Set the extent size of a VG.
  *
  * This API requires calling lvm_vg_write to commit the change to disk.
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 4800555..60c6b31 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -68,6 +68,14 @@ int lvm_vg_extend(vg_t *vg, const char *device)
 	return 0;
 }
 
+int lvm_vg_reduce(vg_t *vg, const char *device)
+{
+	if (vg_read_error(vg))
+		return 0;
+
+	return vg_reduce(vg, (char *)device);
+}
+
 int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size)
 {
 	if (vg_read_error(vg))
@@ -80,15 +88,32 @@ int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size)
 
 int lvm_vg_write(vg_t *vg)
 {
+	struct pv_list *pvl;
+
 	if (vg_read_error(vg))
 		return -1;
 
+	if (dm_list_empty(&vg->pvs)) {
+		log_error("Volume group %s does not contain any physical volumes.\n", vg->name);
+		return -1;
+	}
+
 	if (!archive(vg))
 		return -1;
 
 	/* Store VG on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg))
 		return -1;
+
+	if (! dm_list_empty(&vg->removed_pvs)) {
+		dm_list_iterate_items(pvl, &vg->removed_pvs) {
+			/* FIXME: either use pv_write_orphan or remove the pv */
+			/* pv_write_orphan(vg->cmd, pvl->pv); */
+			label_remove(pv_dev(pvl->pv));
+		}
+		dm_list_init(&vg->removed_pvs);
+	}
+
 	return 0;
 }
 
diff --git a/test/api/vgtest.c b/test/api/vgtest.c
index 4ab9a46..0570e7a 100644
--- a/test/api/vgtest.c
+++ b/test/api/vgtest.c
@@ -26,8 +26,63 @@ lvm_t handle;
 vg_t *vg;
 const char *vg_name = "my_vg";
 const char *device = "/dev/loop3";
+const char *device2 = "/dev/loop4";
 uint64_t size = 1024;
 
+#define vg_create(vg_name) \
+	printf("Creating VG %s\n", vg_name); \
+	vg = lvm_vg_create(handle, vg_name); \
+	if (!vg) { \
+		fprintf(stderr, "Error creating volume group %s\n", vg_name); \
+		goto bad; \
+	}
+#define vg_extend(vg, dev) \
+	printf("Extending VG %s by %s\n", vg_name, dev); \
+	status = lvm_vg_extend(vg, dev); \
+	if (status) { \
+		fprintf(stderr, "Error extending volume group %s " \
+			"with device %s\n", vg_name, dev); \
+		goto bad; \
+	}
+#define vg_commit(vg) \
+	printf("Committing VG %s to disk\n", vg_name); \
+	status = lvm_vg_write(vg); \
+	if (status) { \
+		fprintf(stderr, "Creation of volume group '%s' on " \
+			"device '%s' failed\n", \
+			lvm_vg_get_name(vg), device); \
+		goto bad; \
+	}
+#define vg_open(vg_name, mode) \
+	printf("Opening VG %s %s\n", vg_name, mode); \
+	vg = lvm_vg_open(handle, vg_name, mode, 0); \
+	if (!vg) { \
+		fprintf(stderr, "Error opening volume group %s\n", vg_name); \
+		goto bad; \
+	}
+#define vg_close(vg) \
+	printf("Closing VG %s\n", vg_name); \
+	if (lvm_vg_close(vg)) { \
+		fprintf(stderr, "Error closing volume group %s\n", vg_name); \
+		goto bad; \
+	}
+#define vg_reduce(vg, dev) \
+ 	printf("Reducing VG %s by %s\n", vg_name, dev); \
+	status = lvm_vg_reduce(vg, dev); \
+	if (!status) { \
+		fprintf(stderr, "Error reducing volume group %s " \
+			"by device %s\n", vg_name, dev); \
+		goto bad; \
+	}
+#define vg_remove(vg) \
+ 	printf("Removing VG %s from system\n", vg_name); \
+	status = lvm_vg_remove(vg); \
+	if (status) { \
+		fprintf(stderr, "Revmoval of volume group '%s' failed\n", \
+			vg_name); \
+		goto bad; \
+	}
+
 int main(int argc, char *argv[])
 {
 	int status;
@@ -41,20 +96,8 @@ int main(int argc, char *argv[])
 		goto bad;
 	}
 
-	printf("Creating VG %s\n", vg_name);
-	vg = lvm_vg_create(handle, vg_name);
-	if (!vg) {
-		fprintf(stderr, "Error creating volume group %s\n", vg_name);
-		goto bad;
-	}
-
-	printf("Extending VG %s\n", vg_name);
-	status = lvm_vg_extend(vg, device);
-	if (status) {
-		fprintf(stderr, "Error extending volume group %s "
-			"with device %s\n", vg_name, device);
-		goto bad;
-	}
+	vg_create(vg_name);
+	vg_extend(vg, device);
 
 	printf("Setting VG %s extent_size to %"PRIu64"\n", vg_name, size);
 	status = lvm_vg_set_extent_size(vg, size);
@@ -65,36 +108,25 @@ int main(int argc, char *argv[])
 		goto bad;
 	}
 
-	printf("Committing VG %s to disk\n", vg_name);
-	status = lvm_vg_write(vg);
-	if (status) {
-		fprintf(stderr, "Creation of volume group '%s' on "
-			"device '%s' failed\n",
-			vg_name, device);
-		goto bad;
-	}
+	vg_commit(vg);
+	vg_close(vg);
+	
+	vg_open(vg_name, "r");
+	vg_close(vg);
 
-	printf("Closing VG %s\n", vg_name);
-	if (lvm_vg_close(vg))
-		goto bad;
-	printf("Re-opening VG %s for reading\n", vg_name);
-	vg = lvm_vg_open(handle, vg_name, "r", 0);
-	if (!vg)
-		goto bad;
-	printf("Closing VG %s\n", vg_name);
-	if (lvm_vg_close(vg))
-		goto bad;
-	printf("Re-opening VG %s for writing\n", vg_name);
-	vg = lvm_vg_open(handle, vg_name, "w", 0);
-	if (!vg)
-		goto bad;
-	printf("Removing VG %s from system\n", vg_name);
-	status = lvm_vg_remove(vg);
-	if (status) {
-		fprintf(stderr, "Revmoval of volume group '%s' failed\n",
-			vg_name);
-		goto bad;
-	}
+	vg_open(vg_name, "w");
+	vg_extend(vg, device2);
+	vg_reduce(vg, device);
+	vg_commit(vg);
+	vg_close(vg);
+
+	vg_open(vg_name, "w");
+	vg_extend(vg, device);
+	vg_commit(vg);
+	vg_close(vg);
+
+	vg_open(vg_name, "w");
+	vg_remove(vg);
 
 	lvm_vg_close(vg);
 	lvm_destroy(handle);
-- 
1.6.2.5


