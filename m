From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 23 Feb 2010 10:07:11 -0500
Subject: [PATCH] RFC: move str_list inside lvm2app.h, include lvm2app.h inside lvm-types.h.
In-Reply-To: <4B7D02C9.3000307@redhat.com>
References: <4B7D02C9.3000307@redhat.com>
Message-ID: <1266937631-5215-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm2app exports functions that return lists of strings.  A member of
the string list is defined by a type that is also used internally to
lvm.  Our options seem to be:
1) Duplicate the structure in lvm2app and internal lvm
2) Make internal lvm code include lvm2app.h
3) Use only simple types for return values (use iterator functions)
   a) use char ** for lists of strings
   b) use iterator functions

Option #1 was already sent out.  This patch is an attempt at option #2.
Option #3 might be the best option, though there are some existing
APIs that return dm_lists of strings, and it might be more likely an
application writer would misuse say char **.  If we used iterators it
might be ok, but then again this could be similar to the list type as
far as ease of understanding/use for an application.

This patch makes lvm-types.h include lvm2app.h though, so might not
be the best approach.  Longer term though, the direction is to have
the tools call the library, or some incarnation of it, so including
lvm2app.h from an internal file might fit the longer-term direction
better than duplication.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 include/.symlinks.in       |    1 +
 lib/datastruct/lvm-types.h |    6 ++----
 liblvm/lvm2app.h           |   20 +++++++++++---------
 liblvm/lvm_misc.c          |    4 ++++
 4 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 5a7e556..7651d90 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -58,5 +58,6 @@
 @top_srcdir@/libdm/misc/dm-log-userspace.h
 @top_srcdir@/libdm/misc/dmlib.h
 @top_srcdir@/libdm/misc/kdev_t.h
+ at top_srcdir@/liblvm/lvm2app.h
 @top_srcdir@/po/pogen.h
 @top_srcdir@/tools/lvm2cmd.h
diff --git a/lib/datastruct/lvm-types.h b/lib/datastruct/lvm-types.h
index 5358850..743de9c 100644
--- a/lib/datastruct/lvm-types.h
+++ b/lib/datastruct/lvm-types.h
@@ -19,14 +19,12 @@
 #include <sys/types.h>
 #include <inttypes.h>
 
+#include "lvm2app.h"
+
 /* Define some portable printing types */
 #define PRIsize_t "zu"
 #define PRIptrdiff_t "td"
 #define PRIpid_t PRId32
 
-struct str_list {
-	struct dm_list list;
-	const char *str;
-};
 
 #endif
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index e052301..d172030 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -159,10 +159,12 @@ typedef struct lvm_pv_list {
  * Lists of these structures are returned by lvm_list_vg_names and
  * lvm_list_vg_uuids.
  */
-typedef struct lvm_str_list {
+struct str_list {
 	struct dm_list list;
 	const char *str;
-} lvm_str_list_t;
+};
+
+typedef struct str_list lvm_str_list_t;
 
 /*************************** generic lvm handling ***************************/
 /**
@@ -285,7 +287,7 @@ int lvm_scan(lvm_t libh);
  * To process the list, use the dm_list iterator functions.  For example:
  *      vg_t vg;
  *      struct dm_list *vgnames;
- *      struct lvm_str_list *strl;
+ *      lvm_str_list_t *strl;
  *
  *      vgnames = lvm_list_vg_names(libh);
  *	dm_list_iterate_items(strl, vgnames) {
@@ -297,7 +299,7 @@ int lvm_scan(lvm_t libh);
  *
  *
  * \return
- * A list with entries of type struct lvm_str_list, containing the
+ * A list with entries of type lvm_str_list_t, containing the
  * VG name strings of the Volume Groups known to the system.
  * NULL is returned if unable to allocate memory.
  * An empty list (verify with dm_list_empty) is returned if no VGs
@@ -318,7 +320,7 @@ struct dm_list *lvm_list_vg_names(lvm_t libh);
  * Handle obtained from lvm_init.
  *
  * \return
- * A list with entries of type struct lvm_str_list, containing the
+ * A list with entries of type lvm_str_list_t, containing the
  * VG UUID strings of the Volume Groups known to the system.
  * NULL is returned if unable to allocate memory.
  * An empty list (verify with dm_list_empty) is returned if no VGs
@@ -673,7 +675,7 @@ uint64_t lvm_vg_get_max_lv(const vg_t vg);
  * To process the list, use the dm_list iterator functions.  For example:
  *      vg_t vg;
  *      struct dm_list *tags;
- *      struct lvm_str_list *strl;
+ *      lvm_str_list_t *strl;
  *
  *      tags = lvm_vg_get_tags(vg);
  *	dm_list_iterate_items(strl, tags) {
@@ -683,7 +685,7 @@ uint64_t lvm_vg_get_max_lv(const vg_t vg);
  *
  *
  * \return
- * A list with entries of type struct lvm_str_list, containing the
+ * A list with entries of type lvm_str_list_t, containing the
  * tag strings attached to volume group.
  * If no tags are attached to the given VG, an empty list is returned
  * (check with dm_list_empty()).
@@ -863,7 +865,7 @@ int lvm_lv_remove_tag(lv_t lv, const char *tag);
  * To process the list, use the dm_list iterator functions.  For example:
  *      lv_t lv;
  *      struct dm_list *tags;
- *      struct lvm_str_list *strl;
+ *      lvm_str_list_t *strl;
  *
  *      tags = lvm_lv_get_tags(lv);
  *	dm_list_iterate_items(strl, tags) {
@@ -873,7 +875,7 @@ int lvm_lv_remove_tag(lv_t lv, const char *tag);
  *
  *
  * \return
- * A list with entries of type struct lvm_str_list, containing the
+ * A list with entries of type lvm_str_list_t, containing the
  * tag strings attached to volume group.
  * If no tags are attached to the LV, an empty list is returned
  * (check with dm_list_empty()).
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index f52c563..5fc899c 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -12,7 +12,11 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include <sys/types.h>
+
 #include "lvm_misc.h"
+#include "lvm2app.h"
+#include "lvm-logging.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 {
-- 
1.6.0.6


