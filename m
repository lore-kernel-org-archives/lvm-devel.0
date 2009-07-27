From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 27 Jul 2009 14:27:04 -0400
Subject: [PATCH] Add skeletons of lvm_lv_resize and lvm_pv_resize - not yet implemented.
Message-ID: <1248719224-6658-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Thomas Woerner <twoerner@redhat.com>

These lower-priority interfaces are not currently implemented in liblvm
but are on the TODO list in the near term.

Author: Thomas Woerner <twoerner@redhat.com>
Acked-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm.h    |   24 ++++++++++++++++++++++++
 liblvm/lvm_lv.c |    7 +++++++
 liblvm/lvm_pv.c |    7 +++++++
 3 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index 1247d44..0602e1b 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -565,6 +565,18 @@ uint64_t lvm_lv_is_active(const lv_t *lv);
  */
 uint64_t lvm_lv_is_suspended(const lv_t *lv);
 
+/**
+ * Resize logical volume to new_size bytes.
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \param   new_size
+ *          New size in bytes.
+ * \return  0 (success) or -1 (failure).
+ *
+ */
+int lvm_lv_resize(const lv_t *lv, uint64_t new_size);
+
 /************************** physical volume handling ************************/
 
 /**
@@ -616,4 +628,16 @@ char *lvm_pv_get_name(const pv_t *pv);
  */
 uint64_t lvm_pv_get_mda_count(const pv_t *pv);
 
+/**
+ * Resize physical volume to new_size bytes.
+ *
+ * \param   pv
+ *          Physical volume handle.
+ * \param   new_size
+ *          New size in bytes.
+ * \return  0 (success) or -1 (failure).
+ *
+ */
+int lvm_pv_resize(const pv_t *pv, uint64_t new_size);
+
 #endif /* _LIB_LVM_H */
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index a2436ed..08865ec 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -173,3 +173,10 @@ int lvm_lv_deactivate(lv_t *lv)
 	}
 	return 0;
 }
+
+int lvm_lv_resize(const lv_t *lv, uint64_t new_size)
+{
+	/* FIXME: add lv resize code here */
+	log_error("NOT IMPLEMENTED YET\n");
+	return -1;
+}
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index ea3cee3..872412c 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -42,3 +42,10 @@ uint64_t lvm_pv_get_mda_count(const pv_t *pv)
 {
 	return (uint64_t) pv_mda_count(pv);
 }
+
+int lvm_pv_resize(const pv_t *pv, uint64_t new_size)
+{
+	/* FIXME: add pv resize code here */
+	log_error("NOT IMPLEMENTED YET\n");
+	return -1;
+}
-- 
1.6.0.6


