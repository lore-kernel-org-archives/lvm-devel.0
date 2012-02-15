From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 12:23:17 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20120215122317.20889.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 12:23:16

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-common.c libdm-common.h 

Log message:
	Add DM_DEFAULT_NAME_MANGLING_MODE env. variable to override configured value.
	
	Just in case of emergency when name mangling code causes any problems so
	we can override the default value and switch off the mangling globally.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.564&r2=1.565
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.182&r2=1.183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW_DM	2012/02/15 12:17:34	1.564
+++ LVM2/WHATS_NEW_DM	2012/02/15 12:23:15	1.565
@@ -1,5 +1,7 @@
 Version 1.02.71 - 
 ====================================
+  Add DM_DEFAULT_NAME_MANGLING_MODE env. variable to override configured value.
+  Add dm_lib_init to automatically initialise device-mapper library on load.
   Replace any '\' char with '\\' in table specification on input.
   Add mangle command to dmsetup to provide renaming to correct mangled form.
   Add 'mangled_name' and 'unmangled_name' fields to dmsetup info -c -o.
--- LVM2/libdm/libdevmapper.h	2012/02/15 12:01:28	1.182
+++ LVM2/libdm/libdevmapper.h	2012/02/15 12:23:16	1.183
@@ -365,6 +365,12 @@
  */
 int dm_device_has_mounted_fs(uint32_t major, uint32_t minor);
 
+
+/*
+ * Initialise library
+ */
+void dm_lib_init(void) __attribute__((constructor));
+
 /*
  * Release library resources
  */
--- LVM2/libdm/libdm-common.c	2012/02/15 11:39:38	1.140
+++ LVM2/libdm/libdm-common.c	2012/02/15 12:23:16	1.141
@@ -43,6 +43,8 @@
 #  include <selinux/label.h>
 #endif
 
+#define DM_DEFAULT_NAME_MANGLING_MODE_ENV_VAR_NAME "DM_DEFAULT_NAME_MANGLING_MODE"
+
 #define DEV_DIR "/dev/"
 
 #ifdef UDEV_SYNC_SUPPORT
@@ -66,7 +68,7 @@
 
 static int _verbose = 0;
 static int _suspended_dev_counter = 0;
-static int _name_mangling_mode = DEFAULT_DM_NAME_MANGLING;
+static int _name_mangling_mode = -1;
 
 #ifdef HAVE_SELINUX_LABEL_H
 static struct selabel_handle *_selabel_handle = NULL;
@@ -79,6 +81,22 @@
 static int _udev_checking = 1;
 #endif
 
+void dm_lib_init(void)
+{
+	const char *env;
+
+	env = getenv(DM_DEFAULT_NAME_MANGLING_MODE_ENV_VAR_NAME);
+	if (env && *env) {
+		if (!strcasecmp(env, "none"))
+			_name_mangling_mode = DM_STRING_MANGLING_NONE;
+		else if (!strcasecmp(env, "auto"))
+			_name_mangling_mode = DM_STRING_MANGLING_AUTO;
+		else if (!strcasecmp(env, "hex"))
+			_name_mangling_mode = DM_STRING_MANGLING_HEX;
+	} else
+		_name_mangling_mode = DEFAULT_DM_NAME_MANGLING;
+}
+
 /*
  * Library users can provide their own logging
  * function.
--- LVM2/libdm/libdm-common.h	2012/02/15 11:39:38	1.13
+++ LVM2/libdm/libdm-common.h	2012/02/15 12:23:16	1.14
@@ -18,6 +18,8 @@
 
 #include "libdevmapper.h"
 
+#define DM_DEFAULT_NAME_MANGLING_MODE_ENV_VAR_NAME "DM_DEFAULT_NAME_MANGLING_MODE"
+
 #define DEV_NAME(dmt) (dmt->mangled_dev_name ? : dmt->dev_name)
 
 int mangle_name(const char *str, size_t len, char *buf,


