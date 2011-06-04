From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 4 Jun 2011 21:46:34 -0000
Subject: LVM2/test/api Makefile.in pe_start.c pe_start.sh
Message-ID: <20110604214634.12098.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-04 21:46:34

Modified files:
	test/api       : Makefile.in 
Added files:
	test/api       : pe_start.c pe_start.sh 

Log message:
	Add an API test that shows how to find a value of pe_start for a VG without
	actually creating the VG on-disk.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/pe_start.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/pe_start.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22

/cvs/lvm2/LVM2/test/api/pe_start.c,v  -->  standard output
revision 1.1
--- LVM2/test/api/pe_start.c
+++ -	2011-06-04 21:46:34.530305000 +0000
@@ -0,0 +1,47 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
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
+	vg_t vg = NULL;
+	pv_t pv;
+	struct lvm_property_value v;
+
+	handle = lvm_init(NULL);
+        assert(handle);
+
+	vg = lvm_vg_create(handle, "test_vg");
+        assert(vg);
+
+	if (lvm_vg_extend(vg, argv[1]))
+		abort();
+
+	pv = lvm_pv_from_name(vg, argv[1]);
+	assert(pv);
+
+        v = lvm_pv_get_property(pv, "pe_start");
+        assert(v.is_valid);
+	fprintf(stderr, "pe_start = %d\n", (int)v.value.integer);
+        assert(v.value.integer == 2048 * 512);
+
+        lvm_vg_close(vg);
+	lvm_quit(handle);
+        return 0;
+}
/cvs/lvm2/LVM2/test/api/pe_start.sh,v  -->  standard output
revision 1.1
--- LVM2/test/api/pe_start.sh
+++ -	2011-06-04 21:46:34.614299000 +0000
@@ -0,0 +1,17 @@
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
+aux prepare_devs 2
+aux apitest pe_start $dev1
--- LVM2/test/api/Makefile.in	2011/03/01 21:30:43	1.21
+++ LVM2/test/api/Makefile.in	2011/06/04 21:46:34	1.22
@@ -26,7 +26,7 @@
 wrapper_SOURCES = test.c
 INCLUDES += -I../../include
 
-TARGETS += vgtest.t percent.t
+TARGETS += vgtest.t percent.t pe_start.t
 endif
 
 LVMLIBS = @LVM2APP_LIB@ -ldevmapper


