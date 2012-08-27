From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 27 Aug 2012 11:03:59 +0000 (UTC)
Subject: master - lvm2api: extend lvm2api with lvm_lv_rename
Message-ID: <20120827110359.9F62BA26EF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e52d3167518f5ebbb0296b117a1266874978612f
Commit:        e52d3167518f5ebbb0296b117a1266874978612f
Parent:        92330ba9c8e21451f8406377ae4839f397f369a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 27 23:41:32 2011 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 27 13:02:42 2012 +0200

lvm2api: extend lvm2api with lvm_lv_rename

Add support for LV rename.
---
 WHATS_NEW        |    1 +
 liblvm/lvm2app.h |   16 ++++++++++++++++
 liblvm/lvm_lv.c  |   10 ++++++++++
 3 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 85f8663..28d1908 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Add lvm_lv_rename() to lvm2api.
   Fix setvbuf code by closing and reopening stream before changing buffer.
   Disable private buffering when using liblvm.
   When private stdin/stdout buffering is not used always use silent mode.
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 72c0d79..b758945 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1343,6 +1343,22 @@ int lvm_lv_remove_tag(lv_t lv, const char *tag);
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
index 2d4dc02..d47a857 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -292,6 +292,16 @@ lv_t lvm_lv_from_uuid(vg_t vg, const char *uuid)
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


