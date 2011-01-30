From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:46 +0100
Subject: [PATCH 23/24] Extend lvm2api with lvm_lv_rename
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <01e072a4f4136915edd5b05ccfc726343330bd40.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add support for LV rename
Now useful now mainly for testing various combination of ops stacking.
(following patch).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 liblvm/lvm2app.h |   16 ++++++++++++++++
 liblvm/lvm_lv.c  |   10 ++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 317911d..cb7414c 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1321,6 +1321,22 @@ int lvm_lv_remove_tag(lv_t lv, const char *tag);
  */
 struct dm_list *lvm_lv_get_tags(const lv_t lv);
 
+/**
+ * Rename logical volume to new_name.
+ *
+ * \memberof lv_t
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \param   new_name
+ * New name of logical volume.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ *
+ */
+int lvm_lv_rename(lv_t lv, const char *new_name);
 
 /**
  * Resize logical volume to new_size bytes.
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 664c39d..aef6c5e 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -282,6 +282,16 @@ lv_t lvm_lv_from_uuid(vg_t vg, const char *uuid)
 	}
 	return NULL;
 }
+
+int lvm_lv_rename(lv_t lv, const char *new_name)
+{
+	if (!lv_rename(lv->vg->cmd, lv, new_name)) {
+		log_verbose("LV Rename failed.");
+		return -1;
+	}
+	return 0;
+}
+
 int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
 	/* FIXME: add lv resize code here */
-- 
1.7.3.5


