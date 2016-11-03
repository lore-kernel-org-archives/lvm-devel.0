From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 16:49:43 +0000 (UTC)
Subject: master - libdm: use dm_log_with_errno always
Message-ID: <20161103164943.3209060F1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee13f265f043b47a1b023321fb9e8470fb5703c1
Commit:        ee13f265f043b47a1b023321fb9e8470fb5703c1
Parent:        221d8ff2a420a4104826907de9d71100dc208834
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 3 17:15:07 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 17:49:07 2016 +0100

libdm: use dm_log_with_errno always

Instead of compiling 2 log call for 2 different logging functions,
and runtime decide which version to use - use only 'newer' function
and when user sets his own OLD dm_log logging translate it runtime
for old arg list set.

The positive part is - we get shorter generated library,
on the negative part this translation means, we always have evaluate
all args and print the message into local on stack buffer, before
we can pass this buffer to the users' logging function with proper
expected parameters (and such function may later decide to discard
logging based on message level so whole printing was unnecessary).
---
 WHATS_NEW_DM            |    1 +
 libdm/libdm-common.c    |   62 ++++++++++++++++++++++++++++++++++++++++------
 libdm/misc/dm-logging.h |   10 +------
 3 files changed, 57 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d2d44ac..a4dd6eb 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Use dm_log_with_errno and translate runtime to dm_log only when needed.
   Make log messages from dm and lvm library differnt from dmeventd.
   Notice and Info messages are again logged from dmeventd and its plugins.
   Dmeventd now also respects DM_ABORT_ON_INTERNAL_ERRORS as libdm based tool.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 17f55ab..476f018 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -161,14 +161,59 @@ static void _default_log(int level, const char *file,
 dm_log_fn dm_log = _default_log;
 dm_log_with_errno_fn dm_log_with_errno = _default_log_with_errno;
 
+/*
+ * Wrapper function to reformat new messages to and
+ * old style logging which had not used errno parameter
+ *
+ * As we cannot simply pass '...' to old function we
+ * need to process arg list locally and just pass '%s' + buffer
+ */
+__attribute__((format(printf, 5, 6)))
+static void _log_to_default_log(int level,
+	    const char *file, int line, int dm_errno_or_class,
+	    const char *f, ...)
+{
+	va_list ap;
+	char buf[2 * PATH_MAX + 256]; /* big enough for most messages */
+
+	va_start(ap, f);
+	vsnprintf(buf, sizeof(buf), f, ap);
+	va_end(ap);
+
+	dm_log(level, file, line, "%s", buf);
+}
+
+/*
+ * Wrapper function take 'old' style message without errno
+ * and log it via new logging function with errno arg
+ *
+ * This minor case may happen if new libdm is used with old
+ * recompiled tool that would decided to use new logging,
+ * but still would like to use old binary plugins.
+ */
+__attribute__((format(printf, 4, 5)))
+static void _log_to_default_log_with_errno(int level,
+	    const char *file, int line, const char *f, ...)
+{
+	va_list ap;
+	char buf[2 * PATH_MAX + 256]; /* big enough for most messages */
+
+	va_start(ap, f);
+	vsnprintf(buf, sizeof(buf), f, ap);
+	va_end(ap);
+
+	dm_log_with_errno(level, file, line, 0, "%s", buf);
+}
+
 void dm_log_init(dm_log_fn fn)
 {
-	if (fn)
+	if (fn)  {
 		dm_log = fn;
-	else
+		dm_log_with_errno = _log_to_default_log;
+	} else {
 		dm_log = _default_log;
-
-	dm_log_with_errno = _default_log_with_errno;
+		dm_log_with_errno = _default_log_with_errno;
+	}
 }
 
 int dm_log_is_non_default(void)
@@ -178,12 +223,13 @@ int dm_log_is_non_default(void)
 
 void dm_log_with_errno_init(dm_log_with_errno_fn fn)
 {
-	if (fn)
+	if (fn) {
+		dm_log = _log_to_default_log_with_errno;
 		dm_log_with_errno = fn;
-	else
+	} else {
+		dm_log = _default_log;
 		dm_log_with_errno = _default_log_with_errno;
-
-	dm_log = _default_log;
+	}
 }
 
 void dm_log_init_verbose(int level)
diff --git a/libdm/misc/dm-logging.h b/libdm/misc/dm-logging.h
index 4088bfe..083664d 100644
--- a/libdm/misc/dm-logging.h
+++ b/libdm/misc/dm-logging.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -18,16 +18,10 @@
 
 #include "libdevmapper.h"
 
-extern dm_log_fn dm_log;
 extern dm_log_with_errno_fn dm_log_with_errno;
 
 #define LOG_MESG(l, f, ln, e, x...) \
-	do { \
-		if (dm_log_is_non_default()) \
-			dm_log(l, f, ln, ## x); \
-		else \
-			dm_log_with_errno(l, f, ln, e, ## x); \
-	} while (0)
+	dm_log_with_errno(l, f, ln, e, ## x)
 
 #define LOG_LINE(l, x...) LOG_MESG(l, __FILE__, __LINE__, 0, ## x)
 #define LOG_LINE_WITH_ERRNO(l, e, x...) LOG_MESG(l, __FILE__, __LINE__, e, ## x)


