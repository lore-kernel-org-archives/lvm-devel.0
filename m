From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Jul 2009 03:07:46 -0000
Subject: LVM2 lib/log/lvm-logging.h liblvm/lvm.h
Message-ID: <20090716030746.26247.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-16 03:07:46

Modified files:
	lib/log        : lvm-logging.h 
	liblvm         : lvm.h 

Log message:
	Change default errno value to 0 (no error) and add prototypes in lvm.h
	
	Since we are using errno values, we should use '0' as a default value
	which indicates a non-error, rather than defining some made-up default
	value that is not defined in errno.  If we need to deviate from errno
	values, this will most likely indicate a flaw in our design.
	
	Add prototypes for lvm_errno and lvm_errmsg inside lvm.h and provide
	a basic description of their function.  This fixes a couple compile
	warnings.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/lvm-logging.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/lib/log/lvm-logging.h	2009/07/16 00:52:09	1.6
+++ LVM2/lib/log/lvm-logging.h	2009/07/16 03:07:45	1.7
@@ -16,14 +16,12 @@
 #ifndef _LVM_LOGGING_H
 #define _LVM_LOGGING_H
 
-#define EUNCLASSIFIED -1	/* Generic error code */
-
 void print_log(int level, const char *file, int line, int dm_errno,
 	       const char *format, ...)
     __attribute__ ((format(printf, 5, 6)));
 
 #define LOG_LINE(l, x...) \
-    print_log(l, __FILE__, __LINE__ , EUNCLASSIFIED, ## x)
+    print_log(l, __FILE__, __LINE__ , 0, ## x)
 
 #define LOG_LINE_WITH_ERRNO(l, e, x...) \
     print_log(l, __FILE__, __LINE__ , e, ## x)
--- LVM2/liblvm/lvm.h	2009/07/14 03:02:14	1.3
+++ LVM2/liblvm/lvm.h	2009/07/16 03:07:46	1.4
@@ -72,6 +72,30 @@
 int lvm_reload_config(lvm_t libh);
 
 /**
+ * Return stored error no describing last LVM API error.
+ *
+ * Users of liblvm should use lvm_errno to determine success or failure
+ * of the last call, unless the API indicates another method of determining
+ * success or failure.
+ *
+ * \param   libh
+ *          Handle obtained from lvm_create.
+ *
+ * \return  An errno value describing the last LVM error.
+ */
+int lvm_errno(lvm_t libh);
+
+/**
+ * Return stored error message describing last LVM error.
+ *
+ * \param   libh
+ *          Handle obtained from lvm_create.
+ *
+ * \return  An error string describing the last LVM error.
+ */
+const char *lvm_errmsg(lvm_t libh);
+
+/**
  * Create a VG with default parameters.
  *
  * This API requires calling lvm_vg_write to commit the change to disk.


