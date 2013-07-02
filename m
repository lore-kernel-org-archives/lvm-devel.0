From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:31 +0000 (UTC)
Subject: master - lvm2app: Add function to retrieve the origin.
Message-ID: <20130702192631.E0A9C60FB8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7f3dbf904f369338657785e845ebc8a6f479983
Commit:        a7f3dbf904f369338657785e845ebc8a6f479983
Parent:        9e0260c2e34f1b7150fb2fac3e780c3e75cd411e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Apr 11 16:48:40 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

lvm2app: Add function to retrieve the origin.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm2app.h |   16 ++++++++++++++++
 liblvm/lvm_lv.c  |    5 +++++
 2 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 4a0844e..65dc340 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1232,6 +1232,22 @@ const char *lvm_lv_get_name(const lv_t lv);
 const char *lvm_lv_get_attr(const lv_t lv);
 
 /**
+ * Get the origin of a snapshot.
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
+ * Null if the logical volume is not a snapshot, else origin name.
+ */
+const char *lvm_lv_get_origin(const lv_t lv);
+
+/**
  * Get the current size in bytes of a logical volume.
  *
  * \memberof lv_t
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 6226eac..9f59210 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -62,6 +62,11 @@ const char *lvm_lv_get_attr(const lv_t lv)
 	return lv_attr_dup(lv->vg->vgmem, lv);
 }
 
+const char *lvm_lv_get_origin(const lv_t lv)
+{
+	return lv_origin_dup(lv->vg->vgmem, lv);
+}
+
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
 	return get_property(NULL, NULL, lv, NULL, NULL, NULL, name);


