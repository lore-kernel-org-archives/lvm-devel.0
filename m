From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:47 +0100
Subject: [PATCH 24/24] Testing lvm_lv_rename
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <1487117cf35cc8d8ea29b0fea643c747274bf598.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Test stacking of rename operation within one udev transaction.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/api/Makefile.in |    2 +-
 test/api/lvtest.c    |   64 ++++++++++++++++++++++++++++++++++++++++++++++++++
 test/api/lvtest.sh   |   21 ++++++++++++++++
 3 files changed, 86 insertions(+), 1 deletions(-)
 create mode 100644 test/api/lvtest.c
 create mode 100644 test/api/lvtest.sh

diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index 4c2e887..67b786c 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -24,7 +24,7 @@ test_SOURCES = test.c
 wrapper_SOURCES = test.c
 INCLUDES += -I../../include
 
-UNIT = vgtest.t percent.t
+UNIT = vgtest.t percent.t lvtest.t
 
 LVMLIBS = @LVM2APP_LIB@ -ldevmapper
 DEPLIBS = $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
diff --git a/test/api/lvtest.c b/test/api/lvtest.c
new file mode 100644
index 0000000..c0fee65
--- /dev/null
+++ b/test/api/lvtest.c
@@ -0,0 +1,64 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#undef NDEBUG
+
+#include "lvm2app.h"
+#include "assert.h"
+
+#define err(args...) \
+	do { fprintf(stderr, args); goto bad; } while (0)
+
+int main(int argc, char *argv[])
+{
+	lvm_t handle;
+	vg_t vg;
+	lv_t lv;
+	int r = -1;
+
+	if (!(handle = lvm_init(NULL)))
+                return -1;
+
+	if (!(vg = lvm_vg_open(handle, argv[1], "w", 0)))
+		err("VG open %s failed.\n", argv[1]);
+
+	if (!(lv = lvm_lv_from_name(vg, "test")))
+                err("LV test not found.\n");
+
+	if (lvm_lv_deactivate(lv))
+                err("LV test deactivation failed.\n");
+
+	if (lvm_lv_activate(lv))
+                err("LV test activation failed.\n");
+
+	if (lvm_lv_activate(lv))
+                err("LV test repeated activation failed.\n");
+
+	if (lvm_lv_rename(lv, "test1"))
+		err("LV test rename to test1 failed.\n");
+
+	if (lvm_lv_rename(lv, "test2"))
+		err("LV test1 rename to test2 failed.\n");
+
+	if (lvm_lv_rename(lv, "test"))
+		err("LV test2 rename to test failed.\n");
+
+	if (lvm_vg_close(vg))
+		err("VG close failed.\n");
+
+        r = 0;
+bad:
+	lvm_quit(handle);
+	return r;
+}
diff --git a/test/api/lvtest.sh b/test/api/lvtest.sh
new file mode 100644
index 0000000..516b8b9
--- /dev/null
+++ b/test/api/lvtest.sh
@@ -0,0 +1,21 @@
+#
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+
+. lib/test
+
+aux prepare_vg 1
+
+lvcreate -n test -l 5 $vg
+aux apitest lvtest $vg
+
+check lv_field $vg/test lv_name test
-- 
1.7.3.5


