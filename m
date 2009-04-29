From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 29 Apr 2009 15:55:33 -0400
Subject: [PATCH 7/8] Add lvm_vg_open() and lvm_vg_close for testing.
In-Reply-To: <1241034934-25639-7-git-send-email-dwysocha@redhat.com>
References: <1241034934-25639-1-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-2-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-3-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-4-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-5-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-6-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1241034934-25639-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

- lvm_vg_open: very simplistic version of vg_read()
- export lvm_vg_open and lvm_vg_close

NOTE: This patch is mainly to allow testing of the attribute patches.
I view this patch as peripheral to the attribute patches and is mainly
included for testing so please don't get hung up on it.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    2 ++
 liblvm/lvm.h             |    4 ++++
 liblvm/lvm_base.c        |   25 +++++++++++++++++++++++++
 3 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index d05be6f..3b0ffb8 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -6,3 +6,5 @@ lvm_lv_get_uuid
 lvm_vg_get_name
 lvm_vg_get_uuid
 lvm_lvs_in_vg
+lvm_vg_open
+lvm_vg_close
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index 9574991..47a5270 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -18,6 +18,7 @@
 #include "libdevmapper.h"
 
 #include <stdint.h>
+#include <fcntl.h>
 
 /* Internal object structures */
 struct volume_group;
@@ -104,4 +105,7 @@ int lvm_reload_config(lvm_t libh);
 
 #include "lvm_object_prop.h"
 
+vg_t *lvm_vg_open(lvm_t libh, const char *vg_name, const mode_t mode);
+void lvm_vg_close(vg_t *vg);
+
 #endif /* _LIB_LVM_H */
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 4e235ab..a4a3deb 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -16,6 +16,8 @@
 #include "lvm.h"
 #include "toolcontext.h"
 #include "locking.h"
+#include "metadata-exported.h"
+#include "lvmcache.h"
 
 lvm_t lvm_create(const char *system_dir)
 {
@@ -86,3 +88,26 @@ struct dm_list *lvm_lvs_in_vg(vg_t *vg)
 	}
 	return list;
 }
+
+/*
+ * Open / read a VG.
+ * FIXME: Only read access allowed.
+ */
+vg_t *lvm_vg_open(lvm_t libh, const char *vg_name, mode_t mode)
+{
+	if ((mode & O_ACCMODE) != O_RDONLY) {
+		log_error("Invalid access mode 0x%x for lvm_vg_read()\n",
+			  mode);
+		return NULL;
+	}
+	return vg_lock_and_read((struct cmd_context *)libh,
+				vg_name, NULL, LCK_VG_READ, CLUSTERED, 0);
+}
+
+void lvm_vg_close(vg_t *vg)
+{
+	if (vgname_is_locked(vg->name))
+	    unlock_vg(vg->cmd, vg->name);
+	vg_release(vg);
+}
+
-- 
1.6.0.6


