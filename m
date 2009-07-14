From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 03:08:56 -0000
Subject: LVM2 ./WHATS_NEW test/api/vgcreate.c
Message-ID: <20090714030856.15235.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 03:08:56

Modified files:
	.              : WHATS_NEW 
Added files:
	test/api       : vgcreate.c 

Log message:
	Add liblvm test case for creating of a vg.
	
	liblvm unit test case uses the following APIs:
	- lvm_create, lvm_destroy
	- lvm_vg_create, lvm_vg_extend, lvm_vg_set_extent_size, lvm_vg_write,
	lvm_vg_remove, lvm_vg_close
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgcreate.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1180&r2=1.1181

/cvs/lvm2/LVM2/test/api/vgcreate.c,v  -->  standard output
revision 1.1
--- LVM2/test/api/vgcreate.c
+++ -	2009-07-14 03:08:56.822757000 +0000
@@ -0,0 +1,95 @@
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
+#include "lvm.h"
+
+lvm_t handle;
+vg_t *vg;
+char *vg_name = "my_vg";
+char *device = "/dev/loop3";
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
+	printf("Setting VG %s extent_size to %d\n", vg_name, size);
+	status = lvm_vg_set_extent_size(vg, size);
+	if (!status) {
+		fprintf(stderr, "Can not set physical extent "
+			"size '%ld' for '%s'\n",
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
--- LVM2/WHATS_NEW	2009/07/14 02:19:19	1.1180
+++ LVM2/WHATS_NEW	2009/07/14 03:08:56	1.1181
@@ -1,5 +1,9 @@
 Version 2.02.49 - 
 ================================
+  Add unit test case for liblvm VG create/delete APIs.
+  Add liblvm APIs to implement creation and deletion of VGs.
+  Initialize cmd->cmd_line to "liblvm".
+  Place handles to liblvm objects for pv, vg, lv, lvseg, pvseg inside lvm.h
   Refactor vgsplit and vgextend to remove READ_REQUIRE_RESIZEABLE flag.
   Changed exit() to _exit() after fork(); avoid flushing libc buffers twice.
   Fixed invalid type being passed as printf argument on Sparc64.


