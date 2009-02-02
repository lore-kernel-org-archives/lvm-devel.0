From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 15:50:02 -0500
Subject: [PATCH 06/13] Add lvm_vg_close().
In-Reply-To: <1233607809-1087-6-git-send-email-dwysocha@redhat.com>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1233607809-1087-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For now we cannot free the handle but just check to see if we should
unlock it.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h              |    1 +
 lib/metadata/metadata.c |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index 20c8ce0..85014f5 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -78,4 +78,5 @@ const char *lvm_vg_name(const vg_t *vg);
 const char *lvm_lv_name(const lv_t *lv);
 
 vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode);
+void lvm_vg_close(vg_t *vg);
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 38b6e09..0fa5db4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2486,6 +2486,17 @@ vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode)
 }
 
 /*
+ * Close a VG handle.
+ * If lock is still held, unlock the VG.
+ * FIXME: We cannot free the memory as it's tied to the cmd->mem pool.
+ */
+void lvm_vg_close(vg_t *vg)
+{
+	if (vgname_is_locked(vg->name))
+		unlock_vg(vg->cmd, vg->name);
+}
+
+/*
  * Create a (vg_t) volume group handle from a struct volume_group pointer and a
  * possible failure code or zero for success.
  */
-- 
1.5.5.1


