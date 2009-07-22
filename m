From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 14:36:05 -0400
Subject: [PATCH 1/2] Add lvm_vg_open() to open an existing VG for reading or writing.
In-Reply-To: <1248287766-11552-1-git-send-email-dwysocha@redhat.com>
References: <1248287766-11552-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1248287766-11552-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm_vg_open() calls internal vg_read() function which is the entry point
for reading an existing VG.  In addition to the mode, we include a 'flags'
parameter for future extensions.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    1 +
 liblvm/lvm.h             |   23 +++++++++++++++++++++++
 liblvm/lvm_vg.c          |   26 ++++++++++++++++++++++++++
 3 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index 8f4b6c7..3895c9d 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -5,6 +5,7 @@ lvm_vg_create
 lvm_vg_extend
 lvm_vg_set_extent_size
 lvm_vg_write
+lvm_vg_open
 lvm_vg_close
 lvm_vg_remove
 lvm_errno
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index e179d87..5805546 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -190,4 +190,27 @@ int lvm_vg_remove(vg_t *vg);
  */
 int lvm_vg_close(vg_t *vg);
 
+/**
+ * Open an existing VG.
+ *
+ * Open a VG for reading or writing.
+ *
+ * \param   libh
+ *          Handle obtained from lvm_create.
+ *
+ * \param   vgname
+ *          Name of the VG to open.
+ *
+ * \param   mode
+ *          Open mode - either "r" (read) or "w" (read/write).
+ *          Any other character results in an error with EINVAL set.
+ *
+ * \param   flags
+ *          Open flags - currently ignored.
+ *
+ * \return  non-NULL VG handle (success) or NULL (failure).
+ */
+vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
+		  uint32_t flags);
+
 #endif /* _LIB_LVM_H */
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index f434163..b834875 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -12,6 +12,9 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include <errno.h>
+#include <string.h>
+
 #include "lib.h"
 #include "lvm.h"
 #include "toolcontext.h"
@@ -80,3 +83,26 @@ int lvm_vg_remove(vg_t *vg)
 bad:
 	return 0;
 }
+
+vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
+		  uint32_t flags)
+{
+	uint32_t internal_flags = 0;
+	vg_t *vg;
+
+	if (!strncmp(mode, "w", 1))
+		internal_flags |= READ_FOR_UPDATE;
+	else if (strncmp(mode, "r", 1)) {
+		log_errno(EINVAL, "Invalid VG open mode");
+		return NULL;
+	}
+
+	vg = vg_read((struct cmd_context *)libh, vgname, NULL, internal_flags);
+	if (vg_read_error(vg)) {
+		/* FIXME: use log_errno either here in inside vg_read */
+		vg_release(vg);
+		return NULL;
+	}
+
+	return vg;
+}
-- 
1.6.0.6


