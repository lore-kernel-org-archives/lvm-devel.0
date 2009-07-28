From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jul 2009 11:03:30 -0000
Subject: LVM2 liblvm/.exported_symbols liblvm/lvm.h lib ...
Message-ID: <20090728110330.10010.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-28 11:03:29

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_base.c 
	test/api       : test.c vgtest.c 

Log message:
	Add lvm_library_get_version() and update unit tests to display version.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/liblvm/.exported_symbols	2009/07/28 09:16:18	1.20
+++ LVM2/liblvm/.exported_symbols	2009/07/28 11:03:28	1.21
@@ -1,3 +1,4 @@
+lvm_library_get_version
 lvm_init
 lvm_quit
 lvm_config_reload
--- LVM2/liblvm/lvm.h	2009/07/28 09:56:48	1.36
+++ LVM2/liblvm/lvm.h	2009/07/28 11:03:28	1.37
@@ -28,6 +28,20 @@
  */
 /******************************** WARNING ********************************/
 
+/**
+ * Retrieve the library version.
+ *
+ * The library version is the same format as the full LVM version.
+ * The format is as follows:
+ *    LVM_MAJOR.LVM_MINOR.LVM_PATCHLEVEL(LVM_LIBAPI)[-LVM_RELEASE]
+ * An application wishing to determine compatibility with a particular version
+ * of the library should check at least the LVM_MAJOR, LVM_MINOR, and
+ * LVM_LIBAPI numbers.  For example, assume the full LVM version is
+ * 2.02.50(1)-1.  The application should verify the "2.02" and the "(1)".
+ *
+ * \return  A string describing the library version.
+ */
+const char *lvm_library_get_version(void);
 
 /******************************** structures ********************************/
 
--- LVM2/liblvm/lvm_base.c	2009/07/28 09:16:18	1.9
+++ LVM2/liblvm/lvm_base.c	2009/07/28 11:03:28	1.10
@@ -17,6 +17,11 @@
 #include "toolcontext.h"
 #include "locking.h"
 
+const char *lvm_library_get_version(void)
+{
+	return LVM_VERSION;
+}
+
 lvm_t lvm_init(const char *system_dir)
 {
 	struct cmd_context *cmd;
--- LVM2/test/api/test.c	2009/07/28 09:16:18	1.19
+++ LVM2/test/api/test.c	2009/07/28 11:03:29	1.20
@@ -607,6 +607,7 @@
 		return 1;
 	}
 
+	printf("Library version: %s\n", lvm_library_get_version());
 	lvmapi_test_shell(libh);
 
 	lvm_quit(libh);
--- LVM2/test/api/vgtest.c	2009/07/28 09:16:18	1.7
+++ LVM2/test/api/vgtest.c	2009/07/28 11:03:29	1.8
@@ -96,6 +96,7 @@
 		goto bad;
 	}
 
+	printf("Library version: %s\n", lvm_library_get_version());
 	vg_create(vg_name);
 	vg_extend(vg, device);
 


