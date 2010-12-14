From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Dec 2010 23:21:01 -0000
Subject: LVM2 lib/report/properties.c liblvm/lvm2app.h ...
Message-ID: <20101214232101.12465.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-12-14 23:20:59

Modified files:
	lib/report     : properties.c 
	liblvm         : lvm2app.h lvm_base.c lvm_lv.c lvm_misc.c 
	                 lvm_misc.h lvm_pv.c lvm_vg.c 
	test/api       : Makefile.in 
Added files:
	test/api       : percent.c percent.sh 

Log message:
	Add getters for copy_percent and snap_percent to the lvm2app API.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/lib/report/properties.c	2010/11/25 14:39:02	1.26
+++ LVM2/lib/report/properties.c	2010/12/14 23:20:58	1.27
@@ -16,6 +16,7 @@
 
 #include "libdevmapper.h"
 #include "properties.h"
+#include "activate.h"
 #include "lvm-logging.h"
 #include "lvm-types.h"
 #include "metadata.h"
@@ -85,6 +86,18 @@
 	return 0;
 }
 
+static percent_t _copy_percent(const struct logical_volume *lv) {
+    percent_t perc;
+    lv_mirror_percent(lv->vg->cmd, (struct logical_volume *) lv, 0, &perc, NULL);
+    return perc;
+}
+
+static percent_t _snap_percent(const struct logical_volume *lv) {
+    percent_t perc;
+    lv_snapshot_percent(lv, &perc);
+    return perc;
+}
+
 /* PV */
 GET_PV_STR_PROPERTY_FN(pv_fmt, pv_fmt_dup(pv))
 #define _pv_fmt_set _not_implemented_set
@@ -148,9 +161,9 @@
 #define _origin_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(origin_size, lv_origin_size(lv))
 #define _origin_size_set _not_implemented_set
-#define _snap_percent_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(snap_percent, _snap_percent(lv))
 #define _snap_percent_set _not_implemented_set
-#define _copy_percent_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(copy_percent, _copy_percent(lv))
 #define _copy_percent_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set _not_implemented_set
--- LVM2/liblvm/lvm2app.h	2010/11/25 14:34:51	1.30
+++ LVM2/liblvm/lvm2app.h	2010/12/14 23:20:58	1.31
@@ -1446,8 +1446,10 @@
  * Name of property to query.  See pvs man page for full list of properties
  * that may be queried.
  *
- * The memory allocated for a string property value is tied to the vg_t
- * handle and will be released when lvm_vg_close() is called.
+ * The memory allocated for a string property value is tied to the vg_t handle
+ * and will be released when lvm_vg_close() is called. For "percent" values
+ * (those obtained for copy_percent and snap_percent properties), please see
+ * percent_range_t and lvm_percent_to_float().
  *
  * Example:
  *      lvm_property_value value;
@@ -1578,6 +1580,30 @@
  */
 int lvm_pv_resize(const pv_t pv, uint64_t new_size);
 
+#ifndef _LVM_PERCENT_H
+
+/**
+ * This type defines a couple of special percent values. The PERCENT_0 and
+ * PERCENT_100 constants designate *exact* percentages: values are never
+ * rounded to either of these two.
+ */
+typedef enum {
+	PERCENT_0 = 0,
+	PERCENT_1 = 1000000,
+	PERCENT_100 = 100 * PERCENT_1,
+	PERCENT_INVALID = -1
+} percent_range_t;
+
+typedef int32_t percent_t;
+
+#endif
+
+/**
+ * Convert a (fixed-point) value obtained from the percent-denominated
+ * *_get_property functions into a floating-point value.
+ */
+float lvm_percent_to_float(percent_t v);
+
 #ifdef __cplusplus
 }
 #endif
--- LVM2/liblvm/lvm_base.c	2010/05/19 12:12:47	1.18
+++ LVM2/liblvm/lvm_base.c	2010/12/14 23:20:58	1.19
@@ -13,11 +13,11 @@
  */
 
 #include "lib.h"
-#include "lvm2app.h"
 #include "toolcontext.h"
 #include "locking.h"
 #include "lvm-version.h"
 #include "metadata-exported.h"
+#include "lvm2app.h"
 
 const char *lvm_library_get_version(void)
 {
--- LVM2/liblvm/lvm_lv.c	2010/11/25 14:34:51	1.33
+++ LVM2/liblvm/lvm_lv.c	2010/12/14 23:20:58	1.34
@@ -13,7 +13,6 @@
  */
 
 #include "lib.h"
-#include "lvm2app.h"
 #include "metadata.h"
 #include "lvm-string.h"
 #include "defaults.h"
@@ -21,6 +20,7 @@
 #include "locking.h"
 #include "activate.h"
 #include "lvm_misc.h"
+#include "lvm2app.h"
 
 static int _lv_check_handle(const lv_t lv, const int vg_writeable)
 {
--- LVM2/liblvm/lvm_misc.c	2010/11/17 20:12:40	1.6
+++ LVM2/liblvm/lvm_misc.c	2010/12/14 23:20:58	1.7
@@ -12,10 +12,10 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lvm2app.h"
-#include "lvm_misc.h"
 #include "lib.h"
 #include "properties.h"
+#include "lvm_misc.h"
+#include "lvm2app.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 {
--- LVM2/liblvm/lvm_misc.h	2010/11/17 20:12:40	1.6
+++ LVM2/liblvm/lvm_misc.h	2010/12/14 23:20:58	1.7
@@ -15,6 +15,7 @@
 #define _LVM2APP_MISC_H
 
 #include "libdevmapper.h"
+#include "lvm2app.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
--- LVM2/liblvm/lvm_pv.c	2010/11/25 14:34:51	1.19
+++ LVM2/liblvm/lvm_pv.c	2010/12/14 23:20:58	1.20
@@ -13,10 +13,10 @@
  */
 
 #include "lib.h"
-#include "lvm2app.h"
 #include "metadata.h"
 #include "lvm-string.h"
 #include "lvm_misc.h"
+#include "lvm2app.h"
 
 const char *lvm_pv_get_uuid(const pv_t pv)
 {
--- LVM2/liblvm/lvm_vg.c	2010/12/08 20:50:51	1.49
+++ LVM2/liblvm/lvm_vg.c	2010/12/14 23:20:58	1.50
@@ -13,13 +13,13 @@
  */
 
 #include "lib.h"
-#include "lvm2app.h"
 #include "toolcontext.h"
 #include "metadata.h"
 #include "archiver.h"
 #include "locking.h"
 #include "lvmcache.h"
 #include "lvm_misc.h"
+#include "lvm2app.h"
 
 int lvm_vg_add_tag(vg_t vg, const char *tag)
 {
/cvs/lvm2/LVM2/test/api/percent.c,v  -->  standard output
revision 1.1
--- LVM2/test/api/percent.c
+++ -	2010-12-14 23:21:00.865205000 +0000
@@ -0,0 +1,45 @@
+#include "lvm2app.h"
+
+#define assert(x) do { if (!(x)) goto bad; } while (0)
+
+int main(int argc, char *argv[])
+{
+        lvm_t handle = lvm_init(NULL);
+        assert(handle);
+
+	vg_t vg = lvm_vg_open(handle, argv[1], "r", 0);
+        assert(vg);
+
+        lv_t lv = lvm_lv_from_name(vg, "snap");
+        assert(lv);
+
+        struct lvm_property_value v = lvm_lv_get_property(lv, "snap_percent");
+        assert(v.is_valid);
+        assert(v.value.integer == PERCENT_0);
+
+        lv = lvm_lv_from_name(vg, "mirr");
+        assert(lv);
+
+        v = lvm_lv_get_property(lv, "copy_percent");
+        assert(v.is_valid);
+        assert(v.value.integer == PERCENT_100);
+
+        lv = lvm_lv_from_name(vg, "snap2");
+        assert(lv);
+
+        v = lvm_lv_get_property(lv, "snap_percent");
+        assert(v.is_valid);
+        assert(v.value.integer == 50 * PERCENT_1);
+
+        lvm_vg_close(vg);
+        return 0;
+
+bad:
+	if (handle && lvm_errno(handle))
+		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
+	if (vg)
+		lvm_vg_close(vg);
+	if (handle)
+		lvm_quit(handle);
+	return 1;
+}
/cvs/lvm2/LVM2/test/api/percent.sh,v  -->  standard output
revision 1.1
--- LVM2/test/api/percent.sh
+++ -	2010-12-14 23:21:01.002674000 +0000
@@ -0,0 +1,10 @@
+. ./test-utils.sh
+aux prepare_devs 2
+vgcreate -c n -s 4k $vg $devs
+lvcreate -n foo $vg -l 5
+lvcreate -s -n snap $vg/foo -l 2 -c 4k
+lvcreate -s -n snap2 $vg/foo -l 6 -c 4k
+dd if=/dev/urandom of=$DM_DEV_DIR/$vg/snap2 count=1 bs=1024
+lvcreate -m 1 -n mirr $vg -l 1 --mirrorlog core
+lvs
+apitest percent $vg
--- LVM2/test/api/Makefile.in	2010/12/12 22:26:47	1.18
+++ LVM2/test/api/Makefile.in	2010/12/14 23:20:59	1.19
@@ -24,7 +24,7 @@
 wrapper_SOURCES = test.c
 INCLUDES += -I../../include
 
-UNIT = vgtest.t
+UNIT = vgtest.t percent.t
 
 LVMLIBS = @LVM2APP_LIB@ -ldevmapper
 DEPLIBS = $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so


