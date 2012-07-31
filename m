From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 Jul 2012 14:49:03 +0000 (UTC)
Subject: master - lvm2app: add lvm_config_find_bool function
Message-ID: <20120731144903.449E83171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f64f22e2d657346197fcd0b8e97e87b6d290ab2b
Commit:        f64f22e2d657346197fcd0b8e97e87b6d290ab2b
Parent:        8791d01fee7f5977b037400020db97a40821b94a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 31 16:18:01 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 31 16:18:01 2012 +0200

lvm2app: add lvm_config_find_bool function

To effectively retrieve the setting of anything that could be enabled or disabled.
---
 WHATS_NEW         |    1 +
 liblvm/lvm2app.h  |   22 ++++++++++++++++++++++
 liblvm/lvm_base.c |    5 +++++
 3 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cb3ed90..5208da9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Add lvm_config_find_bool lvm2app fn to retrieve bool value from config tree.
   Respect --test also when using lvmetad.
   No longer capitalise first LV attribute char for invalid snapshots.
   Allow vgextend to add PVs to a VG that is missing PVs.
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index dd200e3..72c0d79 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -303,6 +303,28 @@ int lvm_config_reload(lvm_t libh);
 int lvm_config_override(lvm_t libh, const char *config_string);
 
 /**
+ * Find a boolean value in the LVM configuration.
+ *
+ * \memberof lvm_t
+ *
+ * This function finds a boolean value associated with a path
+ * in current LVM configuration.
+ *
+ * \param   libh
+ * Handle obtained from lvm_init().
+ *
+ * \param   config_path
+ * A path in LVM configuration
+ *
+ * \param   fail
+ * Value to return if the path is not found.
+ *
+ * \return
+ * boolean value for 'config_path' (success) or the value of 'fail' (error)
+ */
+int lvm_config_find_bool(lvm_t libh, const char *config_path, int fail);
+
+/**
  * Return stored error no describing last LVM API error.
  *
  * \memberof lvm_t
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 599c859..2f39b46 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -94,6 +94,11 @@ int lvm_config_override(lvm_t libh, const char *config_settings)
 	return 0;
 }
 
+int lvm_config_find_bool(lvm_t libh, const char *config_path, int fail)
+{
+	return find_config_tree_bool((struct cmd_context *)libh, config_path, fail);
+}
+
 int lvm_errno(lvm_t libh)
 {
 	return stored_errno();


