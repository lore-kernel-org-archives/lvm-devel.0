From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:44 +0000 (UTC)
Subject: master - dmeventd: use log_ macros in plugins
Message-ID: <20151013140344.156D160EDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c90363b585a41de2a65872f9be359db22ee64325
Commit:        c90363b585a41de2a65872f9be359db22ee64325
Parent:        915f0faac1fa3541f4a01092536fac5f2ab5982f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 10 16:58:31 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:09:03 2015 +0200

dmeventd: use log_ macros in plugins

Convert from syslog to standard log_() macros in plugins.
---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c       |   53 +++-----------------
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c  |    8 +--
 daemons/dmeventd/plugins/raid/dmeventd_raid.c      |   10 ++--
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    9 ++--
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |   11 ++--
 5 files changed, 23 insertions(+), 68 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index ecaa058..0ba3694 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2010-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -13,15 +13,11 @@
  */
 
 #include "lib.h"
-#include "log.h"
-
-#include "lvm2cmd.h"
 #include "dmeventd_lvm.h"
+#include "libdevmapper-event.h"
+#include "lvm2cmd.h"
 
 #include <pthread.h>
-#include <syslog.h>
-
-extern int dmeventd_debug;
 
 /*
  * register_device() is called first and performs initialisation.
@@ -36,48 +32,13 @@ static int _register_count = 0;
 static struct dm_pool *_mem_pool = NULL;
 static void *_lvm_handle = NULL;
 
+DM_EVENT_LOG_FN("lvm")
+
 /*
  * Currently only one event can be processed at a time.
  */
 static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
 
-/*
- * FIXME Do not pass things directly to syslog, rather use the existing logging
- * facilities to sort logging ... however that mechanism needs to be somehow
- * configurable and we don't have that option yet
- */
-static void _temporary_log_fn(int level,
-			      const char *file __attribute__((unused)),
-			      int line __attribute__((unused)),
-			      int dm_errno __attribute__((unused)),
-			      const char *message)
-{
-	level &= ~(_LOG_STDERR | _LOG_ONCE);
-
-	switch (level) {
-	case _LOG_DEBUG:
-		if (dmeventd_debug >= 3)
-			syslog(LOG_DEBUG, "%s", message);
-		break;
-	case _LOG_INFO:
-		if (dmeventd_debug >= 2)
-			syslog(LOG_INFO, "%s", message);
-		break;
-	case _LOG_NOTICE:
-		if (dmeventd_debug >= 1)
-			syslog(LOG_NOTICE, "%s", message);
-		break;
-	case _LOG_WARN:
-		syslog(LOG_WARNING, "%s", message);
-		break;
-	case _LOG_ERR:
-		syslog(LOG_ERR, "%s", message);
-		break;
-	default:
-		syslog(LOG_CRIT, "%s", message);
-	}
-}
-
 void dmeventd_lvm2_lock(void)
 {
 	pthread_mutex_lock(&_event_mutex);
@@ -95,8 +56,8 @@ int dmeventd_lvm2_init(void)
 	pthread_mutex_lock(&_register_mutex);
 
 	if (!_lvm_handle) {
-		if (!getenv("LVM_LOG_FILE_EPOCH"))
-			lvm2_log_fn(_temporary_log_fn);
+		lvm2_log_fn((lvm2_log_fn_t)print_log);
+
 		if (!(_lvm_handle = lvm2_init()))
 			goto out;
 
diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 288e741..c010794 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -13,20 +13,18 @@
  */
 
 #include "lib.h"
-
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 #include "defaults.h"
 
-#include <syslog.h> /* FIXME Replace syslog with multilog */
-/* FIXME Missing openlog? */
-/* FIXME Replace most syslogs with log_error() style messages and add complete context. */
 /* FIXME Reformat to 80 char lines. */
 
 #define ME_IGNORE    0
 #define ME_INSYNC    1
 #define ME_FAILURE   2
 
+DM_EVENT_LOG_FN("mirr")
+
 static int _process_status_code(const char status_code, const char *dev_name,
 				const char *dev_type, int r)
 {
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 055bfc2..822d7c4 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -13,13 +13,11 @@
  */
 
 #include "lib.h"
-
-#include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
+#include "libdevmapper-event.h"
+
+DM_EVENT_LOG_FN("raid")
 
-#include <syslog.h> /* FIXME Replace syslog with multilog */
-/* FIXME Missing openlog? */
-/* FIXME Replace most syslogs with log_error() style messages and add complete context. */
 /* FIXME Reformat to 80 char lines. */
 
 /*
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 1372769..f78b8f7 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2007-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -13,14 +13,11 @@
  */
 
 #include "lib.h"
-
-#include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
+#include "libdevmapper-event.h"
 
 #include <sys/wait.h>
-#include <syslog.h> /* FIXME Replace syslog with multilog */
 #include <stdarg.h>
-/* FIXME Missing openlog? */
 
 /* First warning when snapshot is 80% full. */
 #define WARNING_THRESH 80
@@ -38,6 +35,8 @@ struct dso_state {
 	char cmd_str[1024];
 };
 
+DM_EVENT_LOG_FN("snap")
+
 static int _run(const char *cmd, ...)
 {
         va_list ap;
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index febf554..f57eb9b 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -12,15 +12,12 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
-
-#include "libdevmapper-event.h"
+#include "lib.h"	/* using here lvm log */
 #include "dmeventd_lvm.h"
+#include "libdevmapper-event.h"
 
 #include <sys/wait.h>
-#include <syslog.h> /* FIXME Replace syslog with multilog */
 #include <stdarg.h>
-/* FIXME Missing openlog? */
 
 /* First warning when thin is 80% full. */
 #define WARNING_THRESH 80
@@ -52,6 +49,8 @@ struct dso_state {
 #  define MKDEV(x,y) makedev((x),(y))
 #endif
 
+DM_EVENT_LOG_FN("thin")
+
 /* Get dependencies for device, and try to find matching device */
 static int _has_deps(const char *name, int tp_major, int tp_minor, int *dev_minor)
 {


