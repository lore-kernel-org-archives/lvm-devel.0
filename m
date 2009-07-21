From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Jul 2009 10:41:48 -0000
Subject: LVM2/test/api vgcreate.c
Message-ID: <20090721104148.470.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-21 10:41:48

Modified files:
	test/api       : vgcreate.c 

Log message:
	Fix compile warnings in vgcreate liblvm api unit test case.
	
	Use const and PRIu64.
	
	Signed-off-by: Thomas Woerner <twoerner@redhat.com>
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	
	Author: Thomas Woerner <twoerner@redhat.com>
	Committer: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgcreate.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/api/vgcreate.c	2009/07/14 03:08:56	1.1
+++ LVM2/test/api/vgcreate.c	2009/07/21 10:41:47	1.2
@@ -19,12 +19,13 @@
  */
 #include <stdio.h>
 #include <unistd.h>
+#include <inttypes.h>
 #include "lvm.h"
 
 lvm_t handle;
 vg_t *vg;
-char *vg_name = "my_vg";
-char *device = "/dev/loop3";
+const char *vg_name = "my_vg";
+const char *device = "/dev/loop3";
 uint64_t size = 1024;
 
 int main(int argc, char *argv[])
@@ -55,11 +56,11 @@
 		goto bad;
 	}
 
-	printf("Setting VG %s extent_size to %d\n", vg_name, size);
+	printf("Setting VG %s extent_size to %"PRIu64"\n", vg_name, size);
 	status = lvm_vg_set_extent_size(vg, size);
 	if (!status) {
 		fprintf(stderr, "Can not set physical extent "
-			"size '%ld' for '%s'\n",
+			"size '%"PRIu64"' for '%s'\n",
 			size, vg_name);
 		goto bad;
 	}


