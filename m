From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Apr 2011 12:00:00 -0000
Subject: LVM2 ./make.tmpl.in lib/misc/lvm-wrappers.c li ...
Message-ID: <20110422120000.18331.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-04-22 12:00:00

Modified files:
	.              : make.tmpl.in 
	lib/misc       : lvm-wrappers.c lvm-wrappers.h 

Log message:
	Move common libudev code to lvm-wrappers.[ch].
	
	...so we can use it throughout.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-wrappers.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-wrappers.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/make.tmpl.in	2011/02/18 23:09:55	1.116
+++ LVM2/make.tmpl.in	2011/04/22 11:59:59	1.117
@@ -38,7 +38,7 @@
 LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal $(DL_LIBS)
+LVMINTERNAL_LIBS = -llvm-internal $(UDEV_LIBS) $(DL_LIBS)
 DL_LIBS = @DL_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
--- LVM2/lib/misc/lvm-wrappers.c	2008/12/07 04:23:37	1.3
+++ LVM2/lib/misc/lvm-wrappers.c	2011/04/22 12:00:00	1.4
@@ -17,6 +17,91 @@
 #include <unistd.h>
 #include <fcntl.h>
 
+#ifdef UDEV_SYNC_SUPPORT
+static const char _no_context_msg[] = "Udev library context not set.";
+struct udev *_udev;
+
+int udev_init_library_context(void)
+{
+	if (_udev)
+		udev_unref(_udev);
+
+	if (!(_udev = udev_new())) {
+		log_error("Failed to create udev library context.");
+		return 0;
+	}
+
+	return 1;
+}
+
+void udev_fin_library_context(void)
+{
+	udev_unref(_udev);
+	_udev = NULL;
+}
+
+int udev_is_running(void)
+{
+	struct udev_queue *udev_queue;
+	int r;
+
+	if (!_udev) {
+		log_debug(_no_context_msg);
+		goto bad;
+	}
+
+	if (!(udev_queue = udev_queue_new(_udev))) {
+		log_debug("Could not get udev state.");
+		goto bad;
+	}
+
+	r = udev_queue_get_udev_is_active(udev_queue);
+	udev_queue_unref(udev_queue);
+
+	return r;
+
+bad:
+	log_debug("Assuming udev is not running.");
+	return 0;
+}
+
+const char *udev_get_dev_dir(void)
+{
+	if (!_udev) {
+		log_debug(_no_context_msg);
+		return NULL;
+	}
+
+	return udev_get_dev_path(_udev);
+}
+
+struct udev* udev_get_library_context(void)
+{
+	return _udev;
+}
+
+#else	/* UDEV_SYNC_SUPPORT */
+
+int udev_init_library_context(void)
+{
+	return 1;
+}
+
+void udev_fin_library_context(void)
+{
+}
+
+int udev_is_running(void)
+{
+	return 0;
+}
+
+const char *udev_get_dev_dir(void)
+{
+	return NULL;
+}
+#endif
+
 int lvm_getpagesize(void)
 {
 	return getpagesize();
--- LVM2/lib/misc/lvm-wrappers.h	2009/09/28 21:23:02	1.4
+++ LVM2/lib/misc/lvm-wrappers.h	2011/04/22 12:00:00	1.5
@@ -16,6 +16,16 @@
 #ifndef _LVM_WRAPPERS_H
 #define _LVM_WRAPPERS_H
 
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+struct udev *udev_get_library_context(void);
+#endif
+
+int udev_init_library_context(void);
+void udev_fin_library_context(void);
+int udev_is_running(void);
+const char *udev_get_dev_dir(void);
+
 int lvm_getpagesize(void);
 
 /*


