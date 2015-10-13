From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:39 +0000 (UTC)
Subject: master - libdmevent: add dm_event_log
Message-ID: <20151013140339.C6CA260EDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0641e3a5fd19628db0e08fca252c13f40230ffa2
Commit:        0641e3a5fd19628db0e08fca252c13f40230ffa2
Parent:        11a084cf42e79f130e4389bac57688cfd6657fc1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 10 16:40:52 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 14:40:46 2015 +0200

libdmevent: add dm_event_log

Add dm_event_log() logging function.
Controled by dm_event_log_set().
---
 daemons/dmeventd/libdevmapper-event.c |   81 ++++++++++++++++++++++++++++++++-
 daemons/dmeventd/libdevmapper-event.h |   21 ++++++++-
 2 files changed, 99 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 81f18c9..9b04b02 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -12,9 +12,9 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "dm-logging.h"
 #include "dmlib.h"
 #include "libdevmapper-event.h"
-//#include "libmultilog.h"
 #include "dmeventd.h"
 
 #include <fcntl.h>
@@ -23,7 +23,11 @@
 #include <sys/stat.h>
 #include <sys/wait.h>
 #include <arpa/inet.h>		/* for htonl, ntohl */
+#include <pthread.h>
+#include <syslog.h>
 
+static int _debug_level = 0;
+static int _use_syslog = 0;
 static int _sequence_nr = 0;
 
 struct dm_event_handler {
@@ -823,6 +827,79 @@ int dm_event_get_version(struct dm_event_fifos *fifos, int *version) {
 	return 1;
 }
 
+void dm_event_log_set(int debug_level, int use_syslog)
+{
+	_debug_level = debug_level;
+	_use_syslog = use_syslog;
+}
+
+void dm_event_log(const char *subsys, int level, const char *file,
+		  int line, int dm_errno_or_class,
+		  const char *format, va_list ap)
+{
+	static pthread_mutex_t _log_mutex = PTHREAD_MUTEX_INITIALIZER;
+	static time_t start = 0;
+	const char *indent = "";
+	FILE *stream = stdout;
+	int prio = -1;
+	time_t now;
+
+	switch (level & ~(_LOG_STDERR | _LOG_ONCE)) {
+	case _LOG_DEBUG:
+		if (_debug_level < 3)
+			return;
+		prio = LOG_DEBUG;
+		indent = "      ";
+		break;
+	case _LOG_INFO:
+		if (_debug_level < 2)
+			return;
+		prio = LOG_INFO;
+		indent = "    ";
+		break;
+	case _LOG_NOTICE:
+		if (_debug_level < 1)
+			return;
+		prio = LOG_NOTICE;
+		indent = "  ";
+		break;
+	case _LOG_WARN:
+		prio = LOG_WARNING;
+		break;
+	case _LOG_ERR:
+		prio = LOG_ERR;
+		stream = stderr;
+		break;
+	default:
+		prio = LOG_CRIT;
+	}
+
+	/* Serialize to keep lines readable */
+	pthread_mutex_lock(&_log_mutex);
+
+	if (_use_syslog) {
+		vsyslog(prio, format, ap);
+	} else {
+		now = time(NULL);
+		if (!start)
+			start = now;
+		now -= start;
+		fprintf(stream, "[%2d:%02d] %8x:%-6s%s",
+			(int)now / 60, (int)now % 60,
+			// TODO: Maybe use shorter ID
+			// ((int)(pthread_self()) >> 6) & 0xffff,
+			(int)pthread_self(), subsys,
+			(_debug_level > 3) ? "" : indent);
+		if (_debug_level > 3)
+			fprintf(stream, "%28s:%4d %s", file, line, indent);
+		vfprintf(stream, _(format), ap);
+		fputc('\n', stream);
+		fflush(stream);
+	}
+
+	pthread_mutex_unlock(&_log_mutex);
+}
+
 #if 0				/* left out for now */
 
 static char *_skip_string(char *src, const int delimiter)
diff --git a/daemons/dmeventd/libdevmapper-event.h b/daemons/dmeventd/libdevmapper-event.h
index 532bebf..a00702a 100644
--- a/daemons/dmeventd/libdevmapper-event.h
+++ b/daemons/dmeventd/libdevmapper-event.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -105,6 +105,25 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next);
 int dm_event_register_handler(const struct dm_event_handler *dmevh);
 int dm_event_unregister_handler(const struct dm_event_handler *dmevh);
 
+/* Set debug level for logging, and whether to log on stdout/stderr or syslog */
+void dm_event_log_set(int debug_level, int use_syslog);
+
+/* Log messages acroding to current debug level  */
+__attribute__((format(printf, 6, 0)))
+void dm_event_log(const char *subsys, int level, const char *file,
+		  int line, int dm_errno_or_class,
+		  const char *format, va_list ap);
+/* Macro to route print_log do dm_event_log() */
+#define DM_EVENT_LOG_FN(subsys) \
+void print_log(int level, const char *file, int line, int dm_errno_or_class,\
+	       const char *format, ...)\
+{\
+	va_list ap;\
+	va_start(ap, format);\
+	dm_event_log(subsys, level, file, line, dm_errno_or_class, format, ap);\
+	va_end(ap);\
+}
+
 /* Prototypes for DSO interface, see dmeventd.c, struct dso_data for
    detailed descriptions. */
 // FIXME  misuse of bitmask as enum


