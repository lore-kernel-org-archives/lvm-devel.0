From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Dec 2008 04:23:38 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-wrappers.c lib/m ...
Message-ID: <20081207042338.19010.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-07 04:23:37

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-wrappers.c lvm-wrappers.h 
	lib/uuid       : uuid.c 

Log message:
	Add generic function to read /dev/urandom, used in uuid calculation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1004&r2=1.1005
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-wrappers.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-wrappers.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2008/12/04 15:54:26	1.1004
+++ LVM2/WHATS_NEW	2008/12/07 04:23:37	1.1005
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Add generic function to read /dev/urandom, used in uuid calculation.
   Use displayable_lvs_in_vg and lv_is_displayable for consistency throughout.
   Fix race in vgcreate that would result in second caller overwriting first.
   Fix uninitialised lv_count in vgdisplay -c.
--- LVM2/lib/misc/lvm-wrappers.c	2007/08/20 20:55:27	1.2
+++ LVM2/lib/misc/lvm-wrappers.c	2008/12/07 04:23:37	1.3
@@ -15,8 +15,34 @@
 #include "lib.h"
 
 #include <unistd.h>
+#include <fcntl.h>
 
 int lvm_getpagesize(void)
 {
 	return getpagesize();
 }
+
+int read_urandom(void *buf, size_t len)
+{
+	int fd;
+
+	/* FIXME: we should stat here, and handle other cases */
+	/* FIXME: use common _io() routine's open/read/close */
+	if ((fd = open("/dev/urandom", O_RDONLY)) < 0) {
+		log_sys_error("open", "read_urandom: /dev/urandom");
+		return 0;
+	}
+
+	if (read(fd, buf, len) != (ssize_t) len) {
+		log_sys_error("read", "read_urandom: /dev/urandom");
+		if (close(fd))
+			stack;
+		return 0;
+	}
+
+	if (close(fd))
+		stack;
+
+	return 1;
+}
+
--- LVM2/lib/misc/lvm-wrappers.h	2007/08/20 20:55:27	1.2
+++ LVM2/lib/misc/lvm-wrappers.h	2008/12/07 04:23:37	1.3
@@ -18,4 +18,9 @@
 
 int lvm_getpagesize(void);
 
+/*
+ * Read 'len' bytes of entropy from /dev/urandom and store in 'buf'.
+ */
+int read_urandom(void *buf, size_t len);
+
 #endif
--- LVM2/lib/uuid/uuid.c	2008/11/04 15:07:45	1.28
+++ LVM2/lib/uuid/uuid.c	2008/12/07 04:23:37	1.29
@@ -15,6 +15,7 @@
 
 #include "lib.h"
 #include "uuid.h"
+#include "lvm-wrappers.h"
 
 #include <assert.h>
 #include <sys/stat.h>
@@ -94,25 +95,14 @@
 
 int id_create(struct id *id)
 {
-	int randomfile;
 	unsigned i;
 	size_t len = sizeof(id->uuid);
 
 	memset(id->uuid, 0, len);
-	if ((randomfile = open("/dev/urandom", O_RDONLY)) < 0) {
-		log_sys_error("open", "id_create: /dev/urandom");
+	if (!read_urandom(&id->uuid, len)) {
 		return 0;
 	}
 
-	if (read(randomfile, id->uuid, len) != (ssize_t) len) {
-		log_sys_error("read", "id_create: /dev/urandom");
-		if (close(randomfile))
-			stack;
-		return 0;
-	}
-	if (close(randomfile))
-		stack;
-
 	/*
 	 * Skip out the last 2 chars in randomized creation for LVM1
 	 * backwards compatibility.


