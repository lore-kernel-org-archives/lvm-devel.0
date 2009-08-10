From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 10 Aug 2009 14:08:24 -0400
Subject: [PATCH 3/4] Update lvm_vg_write() to handle the deferred commit of lvm_vg_write().
In-Reply-To: <1249927705-28528-3-git-send-email-dwysocha@redhat.com>
References: <1249927705-28528-1-git-send-email-dwysocha@redhat.com>
	<1249927705-28528-2-git-send-email-dwysocha@redhat.com>
	<1249927705-28528-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1249927705-28528-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Now that we've refactored the internal library functions that do the
vg_remove, we can handle the deferred commit of a lvm_vg_remove() inside
lvm_vg_write().  This makes the VG create/remove API more consistent in
terms of disk commits - they now both require an lvm_vg_write() to commit
the create or remove to disk.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h |    4 ++--
 liblvm/lvm_vg.c  |    8 +++-----
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index e509ceb..b1f3999 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -394,8 +394,8 @@ int lvm_vg_write(vg_t *vg);
 /**
  * Remove a VG from the system.
  *
- * This function commits the change to disk and does not require calling
- * lvm_vg_write.
+ * This function removes a Volume Group object in memory, and requires
+ * calling lvm_vg_write to commit the removal to disk.
  *
  * \param   vg
  * VG handle obtained from lvm_vg_create or lvm_vg_open.
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index a659e27..2e93dd0 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -106,9 +106,9 @@ int lvm_vg_write(vg_t *vg)
 		return -1;
 
 	if (dm_list_empty(&vg->pvs)) {
-		log_error("Volume group %s does not contain any "
-			  "physical volumes.", vg->name);
-		return -1;
+		if (!vg_remove_ondisk(vg))
+			return -1;
+		return 0;
 	}
 
 	if (! dm_list_empty(&vg->removed_pvs)) {
@@ -156,8 +156,6 @@ int lvm_vg_remove(vg_t *vg)
 	if (!vg_remove_check(vg))
 		return -1;
 
-	if (!vg_remove_ondisk(vg))
-		return -1;
 	return 0;
 }
 
-- 
1.6.0.6


