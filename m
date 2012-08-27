From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 27 Aug 2012 11:04:02 +0000 (UTC)
Subject: master - tests: testing lvm_lv_rename
Message-ID: <20120827110402.22B4FA26EF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a3c597fd599c21a0bb0c551c92393518d3e70b8
Commit:        5a3c597fd599c21a0bb0c551c92393518d3e70b8
Parent:        e52d3167518f5ebbb0296b117a1266874978612f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 27 23:43:14 2011 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 27 13:03:15 2012 +0200

tests: testing lvm_lv_rename

Test stacking of rename operation within one udev transaction.
---
 test/api/Makefile.in |    4 +-
 test/api/lvtest.c    |   64 ++++++++++++++++++++++++++++++++++++++++++++++++++
 test/api/lvtest.sh   |   21 ++++++++++++++++
 3 files changed, 87 insertions(+), 2 deletions(-)

diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index 324d00b..58d0a23 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -20,8 +20,8 @@ ifeq ("@APPLIB@", "yes")
 TARGETS += test
 SOURCES = test.c
 
-TARGETS += vgtest.t percent.t pe_start.t
-SOURCES2 = vgtest.c percent.c pe_start.c
+TARGETS += vgtest.t percent.t pe_start.t lvtest.t
+SOURCES2 = vgtest.c percent.c pe_start.c lvtest.c
 endif
 
 include $(top_builddir)/make.tmpl
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
index 0000000..0b7684a
--- /dev/null
+++ b/test/api/lvtest.sh
@@ -0,0 +1,21 @@
+#!/bin/sh
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


