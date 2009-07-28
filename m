From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jul 2009 09:16:19 -0000
Subject: LVM2 liblvm/.exported_symbols liblvm/lvm.h lib ...
Message-ID: <20090728091619.21012.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-28 09:16:18

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_base.c 
	test/api       : test.c vgtest.c 

Log message:
	Rename lvm_create to lvm_init and lvm_destroy to lvm_quit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/liblvm/.exported_symbols	2009/07/27 21:02:17	1.19
+++ LVM2/liblvm/.exported_symbols	2009/07/28 09:16:18	1.20
@@ -1,5 +1,5 @@
-lvm_create
-lvm_destroy
+lvm_init
+lvm_quit
 lvm_config_reload
 lvm_config_override
 lvm_pv_get_name
--- LVM2/liblvm/lvm.h	2009/07/28 00:36:58	1.34
+++ LVM2/liblvm/lvm.h	2009/07/28 09:16:18	1.35
@@ -119,7 +119,7 @@
 /**
  * Create a LVM handle.
  *
- * Once all LVM operations have been completed, use lvm_destroy to release
+ * Once all LVM operations have been completed, use lvm_quit to release
  * the handle and any associated resources.
  *
  * \param   system_dir
@@ -132,11 +132,11 @@
  */
 // FIXME: Sort out this alignment.  "Set an" directly below "system_dir"
 // looks awful.  Indent differently?  More blank lines?
-lvm_t lvm_create(const char *system_dir);
+lvm_t lvm_init(const char *system_dir);
 // FIXME Find a better name.  lvm_init.
 
 /**
- * Destroy a LVM handle allocated with lvm_create.
+ * Destroy a LVM handle allocated with lvm_init.
  *
  * This function should be used after all LVM operations are complete or after
  * an unrecoverable error.  Destroying the LVM handle frees the memory and
@@ -144,9 +144,9 @@
  * cannot be used subsequently.
  *
  * \param   libh
- *          Handle obtained from lvm_create.
+ *          Handle obtained from lvm_init.
  */
-void lvm_destroy(lvm_t libh);
+void lvm_quit(lvm_t libh);
 
 /**
  * Reload the original configuration from the system directory.
@@ -156,7 +156,7 @@
  * the application.
  *
  * \param   libh
- *          Handle obtained from lvm_create.
+ *          Handle obtained from lvm_init.
  * \return  0 (success) or -1 (failure).
  */
 int lvm_config_reload(lvm_t libh);
@@ -170,7 +170,7 @@
  * you should use lvm_config_reload to apply the new settings.
  *
  * \param   libh
- *          Handle obtained from lvm_create.
+ *          Handle obtained from lvm_init.
  * \param   config_string
  *          LVM configuration string to apply.  See the lvm.conf file man page
  *          for the format of the config string.
@@ -190,7 +190,7 @@
  * returns a value.
  *
  * \param   libh
- *          Handle obtained from lvm_create.
+ *          Handle obtained from lvm_init.
  *
  * \return  An errno value describing the last LVM error.
  */
@@ -203,7 +203,7 @@
  * specific error information for a function that is known to have failed.
  *
  * \param   libh
- *          Handle obtained from lvm_create.
+ *          Handle obtained from lvm_init.
  *
  * \return  An error string describing the last LVM error.
  */
@@ -223,7 +223,7 @@
  * Return the list of volume group names.
  *
  * The memory allocated for the list is tied to the lvm_t handle and will be
- * released when lvm_destroy is called.
+ * released when lvm_quit is called.
  *
  * NOTE: This function normally does not scan devices in the system for LVM
  * metadata.  To scan the system, use lvm_scan.
@@ -256,7 +256,7 @@
  * Return the list of volume group uuids.
  *
  * The memory allocated for the list is tied to the lvm_t handle and will be
- * released when lvm_destroy is called.
+ * released when lvm_quit is called.
  *
  * NOTE: This function normally does not scan devices in the system for LVM
  * metadata.  To scan the system, use lvm_scan.
@@ -264,7 +264,7 @@
  * begin with a "#" and should be filtered out and not used.
  *
  * \param   libh
- *          Handle obtained from lvm_create.
+ *          Handle obtained from lvm_init.
  *
  * \return  A list with entries of type struct lvm_str_list, containing the
  *          VG UUID strings of the Volume Groups known to the system.
@@ -280,7 +280,7 @@
  * Open a VG for reading or writing.
  *
  * \param   libh
- *          Handle obtained from lvm_create.
+ *          Handle obtained from lvm_init.
  * \param   vgname
  *          Name of the VG to open.
  * \param   mode
@@ -306,7 +306,7 @@
  * release the VG handle.
  *
  * \param   libh
- *          Handle obtained from lvm_create.
+ *          Handle obtained from lvm_init.
  * \param   vg_name
  *          Name of the VG to open.
  * \return  non-NULL vg handle (success) or NULL (failure)
--- LVM2/liblvm/lvm_base.c	2009/07/27 21:02:35	1.8
+++ LVM2/liblvm/lvm_base.c	2009/07/28 09:16:18	1.9
@@ -17,7 +17,7 @@
 #include "toolcontext.h"
 #include "locking.h"
 
-lvm_t lvm_create(const char *system_dir)
+lvm_t lvm_init(const char *system_dir)
 {
 	struct cmd_context *cmd;
 
@@ -46,7 +46,7 @@
 	if (!init_locking(-1, cmd)) {
 		/* FIXME: use EAGAIN as error code here */
 		log_error("Locking initialisation failed.");
-		lvm_destroy((lvm_t) cmd);
+		lvm_quit((lvm_t) cmd);
 		return NULL;
 	}
 	/*
@@ -59,7 +59,7 @@
 	return (lvm_t) cmd;
 }
 
-void lvm_destroy(lvm_t libh)
+void lvm_quit(lvm_t libh)
 {
 	destroy_toolcontext((struct cmd_context *)libh);
 }
--- LVM2/test/api/test.c	2009/07/27 21:02:51	1.18
+++ LVM2/test/api/test.c	2009/07/28 09:16:18	1.19
@@ -601,7 +601,7 @@
 {
 	lvm_t libh;
 
-	libh = lvm_create(NULL);
+	libh = lvm_init(NULL);
 	if (!libh) {
 		printf("Unable to open lvm library instance\n");
 		return 1;
@@ -609,7 +609,7 @@
 
 	lvmapi_test_shell(libh);
 
-	lvm_destroy(libh);
+	lvm_quit(libh);
 	return 0;
 }
 
--- LVM2/test/api/vgtest.c	2009/07/27 17:44:58	1.6
+++ LVM2/test/api/vgtest.c	2009/07/28 09:16:18	1.7
@@ -90,9 +90,9 @@
 	/* FIXME: input vgname, etc from cmdline */
 	/* FIXME: make the below messages verbose-only and print PASS/FAIL*/
 	printf("Opening LVM\n");
-	handle = lvm_create(NULL);
+	handle = lvm_init(NULL);
 	if (!handle) {
-		fprintf(stderr, "Unable to lvm_create\n");
+		fprintf(stderr, "Unable to lvm_init\n");
 		goto bad;
 	}
 
@@ -129,7 +129,7 @@
 	vg_remove(vg);
 	vg_close(vg);
 
-	lvm_destroy(handle);
+	lvm_quit(handle);
 	printf("liblvm vgcreate unit test PASS\n");
 	_exit(0);
 bad:
@@ -139,6 +139,6 @@
 	if (vg)
 		lvm_vg_close(vg);
 	if (handle)
-		lvm_destroy(handle);
+		lvm_quit(handle);
 	_exit(-1);
 }


