From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Mar 2021 11:10:10 +0000 (GMT)
Subject: main - libdm: use libdm header util.h
Message-ID: <20210330111010.D17863861031@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=648188df2a9ba7528f60a9362860d7615227061b
Commit:        648188df2a9ba7528f60a9362860d7615227061b
Parent:        f1e8437c59882a71a9a6e005d188a12a35f0cf9b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 29 22:43:36 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 30 13:08:14 2021 +0200

libdm: use libdm header util.h

Avoid using lvm header for libdm build.
---
 libdm/dm-tools/util.h | 41 +++++++++++++++++++++++++++++++++++++++++
 libdm/misc/dmlib.h    |  2 +-
 2 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/libdm/dm-tools/util.h b/libdm/dm-tools/util.h
index 730b90370..3925a7438 100644
--- a/libdm/dm-tools/util.h
+++ b/libdm/dm-tools/util.h
@@ -76,4 +76,45 @@
 
 #define FMTVGID "%." DM_TO_STRING(ID_LEN) "s"
 
+/*
+ * GCC 3.4 adds a __builtin_clz, which uses the count leading zeros (clz)
+ * instruction on arches that have one. Provide a fallback using shifts
+ * and comparisons for older compilers.
+ */
+#ifdef HAVE___BUILTIN_CLZ
+#define clz(x) __builtin_clz((x))
+#else /* ifdef HAVE___BUILTIN_CLZ */
+static unsigned _dm_clz(unsigned x)
+{
+	int n;
+
+	if ((int)x <= 0) return (~x >> 26) & 32;
+
+	n = 1;
+
+	if ((x >> 16) == 0) {
+		n = n + 16;
+		x = x << 16;
+	}
+
+	if ((x >> 24) == 0) {
+		n = n + 8;
+		x = x << 8;
+	}
+
+	if ((x >> 28) == 0) {
+		n = n + 4;
+		x = x << 4;
+	}
+
+	if ((x >> 30) == 0) {
+		n = n + 2;
+		x = x << 2;
+	}
+	n = n - (x >> 31);
+	return n;
+}
+#define clz(x) _dm_clz((x))
+#endif /* ifdef HAVE___BUILTIN_CLZ */
+
 #endif
diff --git a/libdm/misc/dmlib.h b/libdm/misc/dmlib.h
index 22328696b..85a22c50f 100644
--- a/libdm/misc/dmlib.h
+++ b/libdm/misc/dmlib.h
@@ -72,7 +72,7 @@
 #define DM_EXPORT_SYMBOL_BASE(func)
 #endif
 
-#include "lib/misc/util.h"
+#include "libdm/dm-tools/util.h"
 
 #include "libdm/libdevmapper.h"
 #include "libdm/misc/dm-logging.h"


