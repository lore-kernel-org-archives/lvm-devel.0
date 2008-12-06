From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sat,  6 Dec 2008 11:12:45 -0500
Subject: [PATCH 1/2] Add generic function to read /dev/urandom, used in uuid calculation.
Message-ID: <1228579966-27083-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 include/.symlinks |    1 +
 lib/Makefile.in   |    1 +
 lib/misc/random.c |   29 +++++++++++++++++++++++++++++
 lib/misc/random.h |   20 ++++++++++++++++++++
 lib/uuid/uuid.c   |   14 ++------------
 5 files changed, 53 insertions(+), 12 deletions(-)
 create mode 100644 lib/misc/random.c
 create mode 100644 lib/misc/random.h

diff --git a/include/.symlinks b/include/.symlinks
index b70b96d..9039f67 100644
--- a/include/.symlinks
+++ b/include/.symlinks
@@ -47,6 +47,7 @@
 ../lib/misc/lvm-globals.h
 ../lib/misc/lvm-string.h
 ../lib/misc/lvm-wrappers.h
+../lib/misc/random.h
 ../lib/misc/sharedlib.h
 ../lib/report/report.h
 ../lib/uuid/uuid.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 54092cd..71f98d7 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -80,6 +80,7 @@ SOURCES =\
 	misc/lvm-globals.c \
 	misc/lvm-string.c \
 	misc/lvm-wrappers.c \
+	misc/random.c \
 	misc/timestamp.c \
 	misc/util.c \
 	mm/memlock.c \
diff --git a/lib/misc/random.c b/lib/misc/random.c
new file mode 100644
index 0000000..8ebfb89
--- /dev/null
+++ b/lib/misc/random.c
@@ -0,0 +1,29 @@
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+
+#include "lib.h"
+#include "random.h"
+
+int read_urandom(void *buf, size_t len)
+{
+	int fd;
+
+	if ((fd = open("/dev/urandom", O_RDONLY)) < 0) {
+		log_sys_error("open", "get_random: /dev/urandom");
+		return 0;
+	}
+
+	if (read(fd, buf, len) != (ssize_t) len) {
+		log_sys_error("read", "get_random: /dev/urandom");
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
diff --git a/lib/misc/random.h b/lib/misc/random.h
new file mode 100644
index 0000000..1347fdd
--- /dev/null
+++ b/lib/misc/random.h
@@ -0,0 +1,20 @@
+/*
+ * Copyright (C) 2008 Red Hat, Inc. All rights reserved.
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
+
+#ifndef _LVM_RANDOM_H
+#define _LVM_RANDOM_H
+
+int read_urandom(void *buf, size_t len);
+
+#endif
diff --git a/lib/uuid/uuid.c b/lib/uuid/uuid.c
index 39252c0..5069d1d 100644
--- a/lib/uuid/uuid.c
+++ b/lib/uuid/uuid.c
@@ -15,6 +15,7 @@
 
 #include "lib.h"
 #include "uuid.h"
+#include "random.h"
 
 #include <assert.h>
 #include <sys/stat.h>
@@ -94,25 +95,14 @@ int lvid_in_restricted_range(union lvid *lvid)
 
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
-- 
1.5.5.1


