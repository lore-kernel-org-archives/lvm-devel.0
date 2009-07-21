From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Jul 2009 10:46:45 -0000
Subject: LVM2/test/api vgtest.c vgcreate.c
Message-ID: <20090721104645.1719.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-21 10:46:45

Added files:
	test/api       : vgtest.c 
Removed files:
	test/api       : vgcreate.c 

Log message:
	Rename test/api/vgcreate.c to vgtest.c to reduce filename conflicts in tree.
	
	Signed-off-by: Thomas Woerner <twoerner@redhat.com>
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgcreate.c.diff?cvsroot=lvm2&r1=1.2&r2=NONE

/cvs/lvm2/LVM2/test/api/vgtest.c,v  -->  standard output
revision 1.1
--- LVM2/test/api/vgtest.c
+++ -	2009-07-21 10:46:45.346266000 +0000
@@ -0,0 +1,96 @@
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
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
+/*
+ * Unit test case for vgcreate and related APIs.
+ * # gcc -g vgcreate.c -I../../liblvm -I../../include -L../../liblvm \
+ *   -L../../libdm -ldevmapper -llvm2app
+ * # export LD_LIBRARY_PATH=`pwd`/../../libdm:`pwd`/../../liblvm
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <inttypes.h>
+#include "lvm.h"
+
+lvm_t handle;
+vg_t *vg;
+const char *vg_name = "my_vg";
+const char *device = "/dev/loop3";
+uint64_t size = 1024;
+
+int main(int argc, char *argv[])
+{
+	int status;
+
+	/* FIXME: input vgname, etc from cmdline */
+	/* FIXME: make the below messages verbose-only and print PASS/FAIL*/
+	printf("Opening LVM\n");
+	handle = lvm_create(NULL);
+	if (!handle) {
+		fprintf(stderr, "Unable to lvm_create\n");
+		goto bad;
+	}
+
+	printf("Creating VG %s\n", vg_name);
+	vg = lvm_vg_create(handle, vg_name);
+	if (!vg) {
+		fprintf(stderr, "Error creating volume group %s\n", vg_name);
+		goto bad;
+	}
+
+	printf("Extending VG %s\n", vg_name);
+	status = lvm_vg_extend(vg, device);
+	if (!status) {
+		fprintf(stderr, "Error extending volume group %s "
+			"with device %s\n", vg_name, device);
+		goto bad;
+	}
+
+	printf("Setting VG %s extent_size to %"PRIu64"\n", vg_name, size);
+	status = lvm_vg_set_extent_size(vg, size);
+	if (!status) {
+		fprintf(stderr, "Can not set physical extent "
+			"size '%"PRIu64"' for '%s'\n",
+			size, vg_name);
+		goto bad;
+	}
+
+	printf("Committing VG %s to disk\n", vg_name);
+	status = lvm_vg_write(vg);
+	if (!status) {
+		fprintf(stderr, "Creation of volume group '%s' on "
+			"device '%s' failed\n",
+			vg_name, device);
+		goto bad;
+	}
+
+	printf("Removing VG %s from system\n", vg_name);
+	status = lvm_vg_remove(vg);
+	if (!status) {
+		fprintf(stderr, "Revmoval of volume group '%s' failed\n",
+			vg_name);
+		goto bad;
+	}
+
+	lvm_vg_close(vg);
+	lvm_destroy(handle);
+	printf("liblvm vgcreate unit test PASS\n");
+	_exit(0);
+bad:
+	printf("liblvm vgcreate unit test FAIL\n");
+	if (vg)
+		lvm_vg_close(vg);
+	if (handle)
+		lvm_destroy(handle);
+	_exit(-1);
+}


