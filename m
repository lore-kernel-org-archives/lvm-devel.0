From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 18 Aug 2016 13:07:27 +0000 (UTC)
Subject: master - lib: Move lcm and gcd to lib/misc for wider use.
Message-ID: <20160818130727.618B860756@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c27963c56630417b7a91d073c9a73f54f3fb5c99
Commit:        c27963c56630417b7a91d073c9a73f54f3fb5c99
Parent:        8c71fc1cc21272c8b9e8828b0c6962fd06ec3949
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Aug 18 14:06:13 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Aug 18 14:06:13 2016 +0100

lib: Move lcm and gcd to lib/misc for wider use.

---
 WHATS_NEW                 |    1 +
 include/.symlinks.in      |    1 +
 lib/Makefile.in           |    1 +
 lib/metadata/pool_manip.c |   24 +-----------------------
 lib/misc/lib.h            |    1 +
 lib/misc/lvm-maths.c      |   38 ++++++++++++++++++++++++++++++++++++++
 lib/misc/lvm-maths.h      |   24 ++++++++++++++++++++++++
 7 files changed, 67 insertions(+), 23 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ae6bbea..e2a9622 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Move lcm and gcd to lib/misc.
   Suppress some unnecessary --stripesize parameter warnings.
   Fix 'pvmove -n name ...' to prohibit collocation of RAID SubLVs
 
diff --git a/include/.symlinks.in b/include/.symlinks.in
index d1cc826..a1b5c1e 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -50,6 +50,7 @@
 @top_srcdir@/lib/misc/lvm-file.h
 @top_srcdir@/lib/misc/lvm-flock.h
 @top_srcdir@/lib/misc/lvm-globals.h
+ at top_srcdir@/lib/misc/lvm-maths.h
 @top_srcdir@/lib/misc/lvm-percent.h
 @top_srcdir@/lib/misc/lvm-signal.h
 @top_srcdir@/lib/misc/lvm-string.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 451d96d..c75ffc2 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -112,6 +112,7 @@ SOURCES =\
 	misc/lvm-file.c \
 	misc/lvm-flock.c \
 	misc/lvm-globals.c \
+	misc/lvm-maths.c \
 	misc/lvm-signal.c \
 	misc/lvm-string.c \
 	misc/lvm-wrappers.c \
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 87ca992..f292a0c 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -430,28 +430,6 @@ int validate_pool_chunk_size(struct cmd_context *cmd,
 	return r;
 }
 
-/* Greatest common divisor */
-static unsigned long _gcd(unsigned long n1, unsigned long n2)
-{
-	unsigned long remainder;
-
-	do {
-		remainder = n1 % n2;
-		n1 = n2;
-		n2 = remainder;
-	} while (n2);
-
-	return n1;
-}
-
-/* Least common multiple */
-static unsigned long _lcm(unsigned long n1, unsigned long n2)
-{
-	if (!n1 || !n2)
-		return 0;
-	return (n1 * n2) / _gcd(n1, n2);
-}
-
 int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 					       int passed_args,
 					       int chunk_size_calc_policy)
@@ -497,7 +475,7 @@ int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 				continue;
 
 			if (previous_hint)
-				hint = _lcm(previous_hint, hint);
+				hint = lcm(previous_hint, hint);
 			previous_hint = hint;
 			break;
 		case AREA_LV:
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index 916ffef..8ed06f8 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -89,6 +89,7 @@
 #  include "lvm-logging.h"
 #  include "lvm-globals.h"
 #  include "lvm-wrappers.h"
+#  include "lvm-maths.h"
 #endif
 
 #include <unistd.h>
diff --git a/lib/misc/lvm-maths.c b/lib/misc/lvm-maths.c
new file mode 100644
index 0000000..df3aa0a
--- /dev/null
+++ b/lib/misc/lvm-maths.c
@@ -0,0 +1,38 @@
+/*
+ * Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "lib.h"
+
+/* Greatest common divisor */
+unsigned long gcd(unsigned long n1, unsigned long n2)
+{
+	unsigned long remainder;
+
+	do {
+		remainder = n1 % n2;
+		n1 = n2;
+		n2 = remainder;
+	} while (n2);
+
+	return n1;
+}
+
+/* Least common multiple */
+unsigned long lcm(unsigned long n1, unsigned long n2)
+{
+	if (!n1 || !n2)
+		return 0;
+
+	return (n1 * n2) / gcd(n1, n2);
+}
diff --git a/lib/misc/lvm-maths.h b/lib/misc/lvm-maths.h
new file mode 100644
index 0000000..f7fc0ad
--- /dev/null
+++ b/lib/misc/lvm-maths.h
@@ -0,0 +1,24 @@
+/*
+ * Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#ifndef _LVM_MATH_H
+#define _LVM_MATH_H
+
+/* Greatest common divisor */
+unsigned long gcd(unsigned long n1, unsigned long n2);
+
+/* Least common multiple */
+unsigned long lcm(unsigned long n1, unsigned long n2);
+
+#endif


