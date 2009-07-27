From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 10:18:52 -0000
Subject: LVM2/liblvm lvm.h lvm_base.c
Message-ID: <20090727101852.15813.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 10:18:51

Modified files:
	liblvm         : lvm.h lvm_base.c 

Log message:
	Rename lvm_reload_config to lvm_config_reload.
	
	The general naming scheme for most liblvm APIs is:
	lvm_<object>_<action>
	
	As there are likely to be other things to do on the lvm 'config' object
	(i.e. lvm_config_set_device_filter), we should use consistent naming.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/liblvm/lvm.h	2009/07/27 08:28:13	1.27
+++ LVM2/liblvm/lvm.h	2009/07/27 10:18:51	1.28
@@ -119,8 +119,8 @@
  * the handle and any associated resources.
  *
  * \param   system_dir
- *          Set an alternative LVM system directory. Use NULL to use the 
- *          default value. If the environment variable LVM_SYSTEM_DIR is set, 
+ *          Set an alternative LVM system directory. Use NULL to use the
+ *          default value. If the environment variable LVM_SYSTEM_DIR is set,
  *          it will override any LVM system directory setting.
  * \return  A valid LVM handle is returned or NULL if there has been a
  *          memory allocation problem. You have to check if an error occured
@@ -146,7 +146,7 @@
  *          Handle obtained from lvm_create.
  * \return  0 (success) or -1 (failure).
  */
-int lvm_reload_config(lvm_t libh);
+int lvm_config_reload(lvm_t libh);
 
 /**
  * Return stored error no describing last LVM API error.
@@ -174,6 +174,7 @@
 
 /**
  * Scan all devices on the system for VGs and LVM metadata.
+ * FIXME: Elaborate on when to use, side-effects, .cache file, etc
  *
  * \return  0 (success) or -1 (failure).
  */
--- LVM2/liblvm/lvm_base.c	2009/07/26 20:28:59	1.5
+++ LVM2/liblvm/lvm_base.c	2009/07/27 10:18:51	1.6
@@ -64,7 +64,7 @@
 	destroy_toolcontext((struct cmd_context *)libh);
 }
 
-int lvm_reload_config(lvm_t libh)
+int lvm_config_reload(lvm_t libh)
 {
 	/* FIXME: re-init locking needed here? */
 	if (refresh_toolcontext((struct cmd_context *)libh))


