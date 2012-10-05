From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  5 Oct 2012 08:38:17 +0000 (UTC)
Subject: master - test: lvm2api thin data_percent
Message-ID: <20121005083817.C0FF5A0C55@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f4f7f70ce94e9692b84a3568aedfceb13466ece
Commit:        7f4f7f70ce94e9692b84a3568aedfceb13466ece
Parent:        39f3c9de0babbe54cecb4cee5b163bf72eab61f4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 5 10:33:41 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 5 10:37:41 2012 +0200

test: lvm2api thin data_percent

---
 test/api/Makefile.in     |   18 +++++++++++--
 test/api/thin_percent.c  |   60 ++++++++++++++++++++++++++++++++++++++++++++++
 test/api/thin_percent.sh |   37 ++++++++++++++++++++++++++++
 3 files changed, 112 insertions(+), 3 deletions(-)

diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index 58d0a23..7ad6743 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2009-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2012 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -20,8 +20,20 @@ ifeq ("@APPLIB@", "yes")
 TARGETS += test
 SOURCES = test.c
 
-TARGETS += vgtest.t percent.t pe_start.t lvtest.t
-SOURCES2 = vgtest.c percent.c pe_start.c lvtest.c
+TARGETS += \
+	lvtest.t \
+	percent.t \
+	pe_start.t \
+	thin_percent.t \
+	vgtest.t
+
+SOURCES2 = \
+	lvtest.c \
+	percent.c \
+	pe_start.c \
+	thin_percent.c \
+	vgtest.c
+
 endif
 
 include $(top_builddir)/make.tmpl
diff --git a/test/api/thin_percent.c b/test/api/thin_percent.c
new file mode 100644
index 0000000..952346f
--- /dev/null
+++ b/test/api/thin_percent.c
@@ -0,0 +1,60 @@
+/*
+ * Copyright (C) 2012 Red Hat, Inc. All rights reserved.
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
+int main(int argc, char *argv[])
+{
+	lvm_t handle;
+	vg_t vg;
+	lv_t lv;
+	struct lvm_property_value v;
+
+	handle = lvm_init(NULL);
+	assert(handle);
+
+	vg = lvm_vg_open(handle, argv[1], "r", 0);
+	assert(vg);
+
+	lv = lvm_lv_from_name(vg, "pool");
+	assert(lv);
+
+	v = lvm_lv_get_property(lv, "data_percent");
+	assert(v.is_valid);
+	assert(v.value.integer == 25 * PERCENT_1);
+
+
+	lv = lvm_lv_from_name(vg, "thin");
+	assert(lv);
+
+	v = lvm_lv_get_property(lv, "data_percent");
+	assert(v.is_valid);
+	assert(v.value.integer == 50 * PERCENT_1);
+
+
+	lv = lvm_lv_from_name(vg, "snap");
+	assert(lv);
+
+	v = lvm_lv_get_property(lv, "data_percent");
+	assert(v.is_valid);
+	assert(v.value.integer == 75 * PERCENT_1);
+
+	lvm_vg_close(vg);
+	lvm_quit(handle);
+
+	return 0;
+}
diff --git a/test/api/thin_percent.sh b/test/api/thin_percent.sh
new file mode 100644
index 0000000..bba33ba
--- /dev/null
+++ b/test/api/thin_percent.sh
@@ -0,0 +1,37 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
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
+aux target_at_least dm-thin-pool 1 0 0 || skip
+
+# disable thin_check if not present in system
+which thin_check || aux lvmconf 'global/thin_check_executable = ""'
+
+aux prepare_devs 2
+
+vgcreate -s 64k $vg $(cat DEVICES)
+
+lvcreate -L5M -T $vg/pool
+
+lvcreate -V1M -T $vg/pool -n thin
+dd if=/dev/urandom of="$DM_DEV_DIR/$vg/thin" count=2 bs=256K
+
+lvcreate -s $vg/thin -n snap
+dd if=/dev/urandom of="$DM_DEV_DIR/$vg/snap" count=3 bs=256K
+
+lvs $vg
+
+aux apitest thin_percent $vg
+
+vgremove -ff $vg


