From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sat, 25 Jul 2009 23:03:39 -0400
Subject: [PATCH] Add lvm_vg_remove_lv liblvm function.
In-Reply-To: <1248577419-25724-1-git-send-email-dwysocha@redhat.com>
References: <1248577419-25724-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1248577419-25724-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a very simple version of lvm_vg_remove_lv.
Since we currently can only create linear LVs, this simple remove function
is adequate.  We must refactor lvremove_single a bit.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    1 +
 liblvm/lvm.h             |   11 +++++++++++
 liblvm/lvm_lv.c          |    6 ++++++
 3 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index 3d42cc7..eb3aee9 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -22,3 +22,4 @@ lvm_vg_list_lvs
 lvm_list_vg_names
 lvm_list_vg_ids
 lvm_vg_create_lv_linear
+lvm_vg_remove_lv
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index a39f198..2bb36ee 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -117,6 +117,17 @@ int lvm_reload_config(lvm_t libh);
 lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size);
 
 /**
+ * Remove a logical volume from a volume group.
+ * This API commits the change to disk and does _not_ require calling
+ * lvm_vg_write.
+ * Currently only removing linear LVs are possible.
+ *
+ * FIXME: This API should probably not commit to disk but require calling
+ * lvm_vg_write.
+ */
+int lvm_vg_remove_lv(lv_t *lv);
+
+/**
  * Return stored error no describing last LVM API error.
  *
  * Users of liblvm should use lvm_errno to determine success or failure
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 5b1b213..a0ee136 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -93,3 +93,9 @@ lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size)
 	return lvl->lv;
 }
 
+int lvm_vg_remove_lv(lv_t *lv)
+{
+	if (!lv || !lv->vg || vg_read_error(lv->vg))
+		return 0;
+	return lv_remove_single(lv->vg->cmd, lv, DONT_PROMPT);
+}
-- 
1.6.0.6


