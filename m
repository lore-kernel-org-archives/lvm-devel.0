From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 29 Jul 2015 18:31:37 +0000 (UTC)
Subject: master - libdm: Add dm_timestamp functions.
Message-ID: <20150729183137.C503960E0B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a28fb37b9e0e5b3a754e897887a8fdb22fd2d98d
Commit:        a28fb37b9e0e5b3a754e897887a8fdb22fd2d98d
Parent:        a5491d36982c7afe10f655ad0592fb20f9a331fd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 29 19:21:07 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 29 19:21:07 2015 +0100

libdm: Add dm_timestamp functions.

---
 WHATS_NEW_DM                        |    1 +
 lib/Makefile.in                     |    5 -
 lib/misc/timestamp.c                |  129 --------------------------
 lib/misc/timestamp.h                |   33 -------
 libdm/.exported_symbols.DM_1_02_104 |    5 +
 libdm/Makefile.in                   |    1 +
 libdm/libdevmapper.h                |   42 +++++++++-
 libdm/libdm-timestamp.c             |  170 +++++++++++++++++++++++++++++++++++
 8 files changed, 218 insertions(+), 168 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dcc2a24..81acfe9 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.104 -
 =================================
+  Add dm_timestamp functions to libdevmapper.
 
 Version 1.02.103 - 24th July 2015
 =================================
diff --git a/lib/Makefile.in b/lib/Makefile.in
index dbd4e3f..e29ff29 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -122,11 +122,6 @@ SOURCES =\
 	uuid/uuid.c \
 	zero/zero.c
 
-ifeq ("@HAVE_REALTIME@", "yes")
-  SOURCES +=\
-	misc/timestamp.c
-endif
-
 ifeq ("@LVM1@", "internal")
   SOURCES +=\
 	format1/disk-rep.c \
diff --git a/lib/misc/timestamp.c b/lib/misc/timestamp.c
deleted file mode 100644
index 47b5586..0000000
--- a/lib/misc/timestamp.c
+++ /dev/null
@@ -1,129 +0,0 @@
-/*
- * Copyright (C) 2006 Rackable Systems All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-/*
- * Abstract out the time methods used so they can be adjusted later -
- * the results of these routines should stay in-core.  This implementation
- * requires librt.
- */
-
-#include "lib.h"
-#include <stdlib.h>
-
-#include "timestamp.h"
-
-/*
- * The realtime section uses clock_gettime with the CLOCK_MONOTONIC
- * parameter to prevent issues with time warps
- */
-#ifdef HAVE_REALTIME
-
-#include <time.h>
-#include <bits/time.h>
-
-struct timestamp {
-	struct timespec t;
-};
-
-struct timestamp *get_timestamp(void)
-{
-	struct timestamp *ts = NULL;
-
-	if (!(ts = dm_malloc(sizeof(*ts))))
-		return_NULL;
-
-	if (clock_gettime(CLOCK_MONOTONIC, &ts->t)) {
-		log_sys_error("clock_gettime", "get_timestamp");
-		return NULL;
-	}
-
-	return ts;
-}
-
-/* cmp_timestamp: Compare two timestamps
- *
- * Return: -1 if t1 is less than t2
- *          0 if t1 is equal to t2
- *          1 if t1 is greater than t2
- */
-int cmp_timestamp(struct timestamp *t1, struct timestamp *t2)
-{
-	if(t1->t.tv_sec < t2->t.tv_sec)
-		return -1;
-	if(t1->t.tv_sec > t2->t.tv_sec)
-		return 1;
-
-	if(t1->t.tv_nsec < t2->t.tv_nsec)
-		return -1;
-	if(t1->t.tv_nsec > t2->t.tv_nsec)
-		return 1;
-
-	return 0;
-}
-
-#else /* ! HAVE_REALTIME */
-
-/*
- * The !realtime section just uses gettimeofday and is therefore subject
- * to ntp-type time warps - not sure if should allow that.
- */
-
-#include <sys/time.h>
-
-struct timestamp {
-	struct timeval t;
-};
-
-struct timestamp *get_timestamp(void)
-{
-	struct timestamp *ts = NULL;
-
-	if (!(ts = dm_malloc(sizeof(*ts))))
-		return_NULL;
-
-	if (gettimeofday(&ts->t, NULL)) {
-		log_sys_error("gettimeofday", "get_timestamp");
-		return NULL;
-	}
-
-	return ts;
-}
-
-/* cmp_timestamp: Compare two timestamps
- *
- * Return: -1 if t1 is less than t2
- *          0 if t1 is equal to t2
- *          1 if t1 is greater than t2
- */
-int cmp_timestamp(struct timestamp *t1, struct timestamp *t2)
-{
-	if(t1->t.tv_sec < t2->t.tv_sec)
-		return -1;
-	if(t1->t.tv_sec > t2->t.tv_sec)
-		return 1;
-
-	if(t1->t.tv_usec < t2->t.tv_usec)
-		return -1;
-	if(t1->t.tv_usec > t2->t.tv_usec)
-		return 1;
-
-	return 0;
-}
-
-#endif /* HAVE_REALTIME */
-
-void destroy_timestamp(struct timestamp *t)
-{
-	dm_free(t);
-}
diff --git a/lib/misc/timestamp.h b/lib/misc/timestamp.h
deleted file mode 100644
index 50e2a85..0000000
--- a/lib/misc/timestamp.h
+++ /dev/null
@@ -1,33 +0,0 @@
-/*
- * Copyright (C) 2006 Rackable Systems All rights reserved.  
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-#ifndef _LVM_TIMESTAMP_H
-#define _LVM_TIMESTAMP_H
-
-struct timestamp;
-
-struct timestamp *get_timestamp(void);
-
-/* cmp_timestamp: Compare two timestamps
- * 
- * Return: -1 if t1 is less than t2
- *  	    0 if t1 is equal to t2
- *          1 if t1 is greater than t2
- */
-int cmp_timestamp(struct timestamp *t1, struct timestamp *t2);
-
-void destroy_timestamp(struct timestamp *t);
-
-#endif /* _LVM_TIMESTAMP_H */
-
diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index 7bd144d..9fafa48 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -1 +1,6 @@
 dm_size_to_string
+dm_timestamp_alloc
+dm_timestamp_compare
+dm_timestamp_get
+dm_timestamp_delta
+dm_timestamp_destroy
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index ba65c6a..73f6f40 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -25,6 +25,7 @@ SOURCES =\
 	libdm-deptree.c \
 	libdm-string.c \
 	libdm-report.c \
+	libdm-timestamp.c \
 	libdm-config.c \
 	mm/dbg_malloc.c \
 	mm/pool.c \
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 3a900be..001d4c0 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1,6 +1,7 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2006 Rackable Systems All rights reserved.  
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -1664,6 +1665,45 @@ typedef int32_t dm_percent_t;
 float dm_percent_to_float(dm_percent_t percent);
 dm_percent_t dm_make_percent(uint64_t numerator, uint64_t denominator);
 
+/********************
+ * timestamp handling
+ ********************/
+
+struct dm_timestamp;
+
+/*
+ * Create a dm_timestamp object to use with dm_timestamp_get.
+ */
+struct dm_timestamp *dm_timestamp_alloc(void);
+
+/*
+ * Update dm_timestamp object to represent the current time.
+ */
+int dm_timestamp_get(struct dm_timestamp *ts);
+
+/*
+ * Compare two timestamps.
+ * 
+ * Return: -1 if ts1 is less than ts2
+ *  	    0 if ts1 is equal to ts2
+ *          1 if ts1 is greater than ts2
+ */
+int dm_timestamp_compare(struct dm_timestamp *ts1, struct dm_timestamp *ts2);
+
+/*
+ * Return the absolute difference in nanoseconds between
+ * the dm_timestamp objects ts1 and ts2.
+ *
+ * Callers that need to know whether ts1 is before, equal to, or after ts2
+ * in addition to the magnitude should use dm_timestamp_compare.
+ */
+uint64_t dm_timestamp_delta(struct dm_timestamp *ts1, struct dm_timestamp *ts2);
+
+/*
+ * Destroy a dm_timestamp object.
+ */
+void dm_timestamp_destroy(struct dm_timestamp *ts);
+
 /*********************
  * reporting functions
  *********************/
diff --git a/libdm/libdm-timestamp.c b/libdm/libdm-timestamp.c
new file mode 100644
index 0000000..d2bd7bf
--- /dev/null
+++ b/libdm/libdm-timestamp.c
@@ -0,0 +1,170 @@
+/*
+ * Copyright (C) 2006 Rackable Systems All rights reserved.
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of the device-mapper userspace tools.
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
+/*
+ * Abstract out the time methods used so they can be adjusted later -
+ * the results of these routines should stay in-core.  
+ */
+
+#include "dmlib.h"
+
+#include <stdlib.h>
+
+#define NSEC_PER_USEC	UINT64_C(1000)
+#define NSEC_PER_MSEC	UINT64_C(1000000)
+#define NSEC_PER_SEC	UINT64_C(1000000000)
+
+/*
+ * The realtime section uses clock_gettime with the CLOCK_MONOTONIC
+ * parameter to prevent issues with time warps
+ * This implementation requires librt.
+ */
+#ifdef HAVE_REALTIME
+
+#include <time.h>
+#include <bits/time.h>
+
+struct dm_timestamp {
+	struct timespec t;
+};
+
+static uint64_t _timestamp_to_uint64(struct dm_timestamp *ts)
+{
+	uint64_t stamp = 0;
+
+	stamp += (uint64_t) ts->t.tv_sec * NSEC_PER_SEC;
+	stamp += (uint64_t) ts->t.tv_nsec;
+
+	return stamp;
+}
+
+struct dm_timestamp *dm_timestamp_alloc(void)
+{
+	struct dm_timestamp *ts = NULL;
+
+	if (!(ts = dm_malloc(sizeof(*ts))))
+		stack;
+
+	return ts;
+}
+
+int dm_timestamp_get(struct dm_timestamp *ts)
+{
+	if (!ts)
+		return 0;
+
+	if (clock_gettime(CLOCK_MONOTONIC, &ts->t)) {
+		log_sys_error("clock_gettime", "get_timestamp");
+		return 0;
+	}
+
+	return 1;
+}
+
+#else /* ! HAVE_REALTIME */
+
+/*
+ * The !realtime section just uses gettimeofday and is therefore subject
+ * to ntp-type time warps - not sure if should allow that.
+ */
+
+#include <sys/time.h>
+
+struct dm_timestamp {
+	struct timeval t;
+};
+
+static uint64_t _timestamp_to_uint64(struct dm_timestamp *ts)
+{
+	uint64_t stamp = 0;
+
+	stamp += ts->t.tv_sec * NSEC_PER_SEC;
+	stamp += ts->t.tv_usec * NSEC_PER_USEC;
+
+	return stamp;
+}
+
+struct dm_timestamp *dm_timestamp_alloc(void)
+{
+	struct dm_timestamp *ts;
+
+	if (!(ts = dm_malloc(sizeof(*ts))))
+		stack;
+
+	return ts;
+}
+
+int dm_timestamp_get(struct dm_timestamp *ts)
+{
+	if (!ts)
+		return 0;
+
+	if (gettimeofday(&ts->t, NULL)) {
+		log_sys_error("gettimeofday", "get_timestamp");
+		return 0;
+	}
+
+	return 1;
+}
+
+#endif /* HAVE_REALTIME */
+
+/*
+ * Compare two timestamps.
+ *
+ * Return: -1 if ts1 is less than ts2
+ *          0 if ts1 is equal to ts2
+ *          1 if ts1 is greater than ts2
+ */
+int dm_timestamp_compare(struct dm_timestamp *ts1, struct dm_timestamp *ts2)
+{
+	uint64_t t1, t2;
+
+	t1 = _timestamp_to_uint64(ts1);
+	t2 = _timestamp_to_uint64(ts2);
+
+	if (t2 < t1)
+		return 1;
+
+	if (t1 < t2)
+		return -1;
+
+	return 0;
+}
+
+/*
+ * Return the absolute difference in nanoseconds between
+ * the dm_timestamp objects ts1 and ts2.
+ *
+ * Callers that need to know whether ts1 is before, equal to, or after ts2
+ * in addition to the magnitude should use dm_timestamp_compare.
+ */
+uint64_t dm_timestamp_delta(struct dm_timestamp *ts1, struct dm_timestamp *ts2)
+{
+	uint64_t t1, t2;
+
+	t1 = _timestamp_to_uint64(ts1);
+	t2 = _timestamp_to_uint64(ts2);
+
+	if (t1 > t2)
+		return t1 - t2;
+
+	return t2 - t1;
+}
+
+void dm_timestamp_destroy(struct dm_timestamp *ts)
+{
+	dm_free(ts);
+}


