From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:27 +0000 (UTC)
Subject: master - lvm2app: Add method to retrieve attr from lv.
Message-ID: <20130702192627.BDB0E60DE3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=952605a8ea3a7c9eabeb89bb3d644b8b04b4239b
Commit:        952605a8ea3a7c9eabeb89bb3d644b8b04b4239b
Parent:        588a16cadbb9000da8d5405ad69d3ed7024fd0fb
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Apr 10 14:37:56 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

lvm2app: Add method to retrieve attr from lv.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm2app.h |   16 ++++++++++++++++
 liblvm/lvm_lv.c  |    5 +++++
 2 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 54a67c0..4a0844e 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1216,6 +1216,22 @@ const char *lvm_lv_get_uuid(const lv_t lv);
 const char *lvm_lv_get_name(const lv_t lv);
 
 /**
+ * Get the attributes of a logical volume.
+ *
+ * \memberof lv_t
+ *
+ * The memory allocated for the name is tied to the vg_t handle and will be
+ * released when lvm_vg_close() is called.
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * Copy of the attributes for the logical volume
+ */
+const char *lvm_lv_get_attr(const lv_t lv);
+
+/**
  * Get the current size in bytes of a logical volume.
  *
  * \memberof lv_t
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index d0f89f1..6226eac 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -57,6 +57,11 @@ const char *lvm_lv_get_name(const lv_t lv)
 			       NAME_LEN+1);
 }
 
+const char *lvm_lv_get_attr(const lv_t lv)
+{
+	return lv_attr_dup(lv->vg->vgmem, lv);
+}
+
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
 	return get_property(NULL, NULL, lv, NULL, NULL, NULL, name);


