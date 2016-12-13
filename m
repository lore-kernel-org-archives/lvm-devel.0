From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:04:33 +0000 (UTC)
Subject: master - util: add clz() and use __builtin_clz() if available
Message-ID: <20161213210433.32CC3603AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=107bc13db3b0117e32bacede53fbd382feaf4a17
Commit:        107bc13db3b0117e32bacede53fbd382feaf4a17
Parent:        83a9cd5258fbd1acf293734cb4c3aba0f9ffcc9b
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Dec 12 12:03:50 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 20:41:29 2016 +0000

util: add clz() and use __builtin_clz() if available

Add a macro for the clz (count leading zeros) operation.

Use the GCC __builtin_clz() for clz() if it is available and fall
back to a shift based implementation on systems that do not set
HAVE___BUILTIN_CLZ.
---
 lib/misc/util.h |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/lib/misc/util.h b/lib/misc/util.h
index 730b903..9231ea9 100644
--- a/lib/misc/util.h
+++ b/lib/misc/util.h
@@ -35,6 +35,47 @@
 #define uninitialized_var(x) x = x
 #endif
 
+/*
+ * GCC 3.4 adds a __builtin_clz, which uses the count leading zeros (clz)
+ * instruction on arches that have one. Provide a fallback using shifts
+ * and comparisons for older compilers.
+ */
+#ifdef HAVE___BUILTIN_CLZ
+#define clz(x) __builtin_clz((x))
+#else /* ifdef HAVE___BUILTIN_CLZ */
+unsigned _dm_clz(unsigned x)
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
 #define KERNEL_VERSION(major, minor, release) (((major) << 16) + ((minor) << 8) + (release))
 
 /* Define some portable printing types */


