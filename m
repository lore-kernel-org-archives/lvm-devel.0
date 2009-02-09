From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:21:52 -0500
Subject: [PATCH 04/21] Add lvm_vg_open().
In-Reply-To: <1234153329-2829-4-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

RFC - lvm_vg_open().  The new vg_read() function is a step in the right
direction but still contains a lot of new options / flags that will
be new to people and we can hopefully simplify.  lvm_vg_open() was
modelled after 'open' which gives us a potential model that others are
familiar with.  Can we use the modes and flags of 'open' in a similar way
or do we need to introduce new flags/concepts to people?  For example,
can we use a some of the open flags such as O_CREAT and O_EXCL to
implement READ_CHECK_EXISTENCE?

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h              |    2 ++
 lib/metadata/metadata.c |   14 ++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index 5f44614..20c8ce0 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -16,6 +16,7 @@
 #define _LIB_LVM2_H
 
 #include <stdint.h>
+#include <fcntl.h>
 
 /*
  * lvm_handle_t
@@ -76,4 +77,5 @@ const char *lvm_pv_name(const pv_t *pv);
 const char *lvm_vg_name(const vg_t *vg);
 const char *lvm_lv_name(const lv_t *lv);
 
+vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode);
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4c9f939..38b6e09 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2472,6 +2472,20 @@ vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 }
 
 /*
+ * Open / read a VG.
+ * FIXME: Only read access allowed.
+ */
+vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode)
+{
+	if ((mode & O_ACCMODE) != O_RDONLY) {
+		log_error("Invalid access mode 0x%x for lvm_vg_read()\n",
+			mode);
+		return NULL;
+	}
+	return vg_read((struct cmd_context *)libh, vg_name, NULL, 0);
+}
+
+/*
  * Create a (vg_t) volume group handle from a struct volume_group pointer and a
  * possible failure code or zero for success.
  */
-- 
1.6.0.5


