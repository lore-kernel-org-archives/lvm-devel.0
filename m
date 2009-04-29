From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 29 Apr 2009 15:55:30 -0400
Subject: [PATCH 4/8] Implement lvm_{vg|lv}_get_{name|uuid}
In-Reply-To: <1241034934-25639-4-git-send-email-dwysocha@redhat.com>
References: <1241034934-25639-1-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-2-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-3-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1241034934-25639-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

- use vg->vgmem pool to dup names and uuids
- add exports for lvm_{vg|lv}_get_{name|uuid}.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    6 +++++-
 liblvm/lvm_object_prop.c |   20 ++++++++++++--------
 2 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index 1b65e10..f00bb19 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -1,3 +1,7 @@
 lvm_create
 lvm_destroy
-lvm_reload_config
\ No newline at end of file
+lvm_reload_config
+lvm_lv_get_name
+lvm_lv_get_uuid
+lvm_vg_get_name
+lvm_vg_get_uuid
diff --git a/liblvm/lvm_object_prop.c b/liblvm/lvm_object_prop.c
index 2b02457..768f2bd 100644
--- a/liblvm/lvm_object_prop.c
+++ b/liblvm/lvm_object_prop.c
@@ -12,6 +12,8 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 #include "lvm.h"
+#include "metadata-exported.h"
+#include "lvm-string.h"
 
 /**
  * lvm_lv_{get|set}_uuid
@@ -19,8 +21,9 @@
  */
 const char *lvm_lv_get_uuid(lv_t *lv)
 {
-    /* FIXME: implement function body */
-    return (const char *)0;
+    return (const char *)dm_pool_strndup(lv->vg->vgmem,
+					(const char *)lv->lvid.id[1].uuid,
+					sizeof(lv->lvid.id[1].uuid));
 }
 int lvm_lv_set_uuid(lv_t *lv, const char *value)
 {
@@ -33,8 +36,8 @@ int lvm_lv_set_uuid(lv_t *lv, const char *value)
  */
 const char *lvm_lv_get_name(lv_t *lv)
 {
-    /* FIXME: implement function body */
-    return (const char *)0;
+    return (const char *)dm_pool_strndup(lv->vg->vgmem, lv->name,
+					 NAME_LEN);
 }
 int lvm_lv_set_name(lv_t *lv, const char *value)
 {
@@ -542,8 +545,9 @@ int lvm_vg_set_fmt(vg_t *vg, const char *value)
  */
 const char *lvm_vg_get_uuid(vg_t *vg)
 {
-    /* FIXME: implement function body */
-    return (const char *)0;
+    return (const char *)dm_pool_strndup(vg->vgmem,
+					(const char *)vg->id.uuid,
+					sizeof(vg->id.uuid));
 }
 int lvm_vg_set_uuid(vg_t *vg, const char *value)
 {
@@ -556,8 +560,8 @@ int lvm_vg_set_uuid(vg_t *vg, const char *value)
  */
 const char *lvm_vg_get_name(vg_t *vg)
 {
-    /* FIXME: implement function body */
-    return (const char *)0;
+    return (const char *)dm_pool_strndup(vg->vgmem, vg->name,
+					 NAME_LEN);
 }
 int lvm_vg_set_name(vg_t *vg, const char *value)
 {
-- 
1.6.0.6


