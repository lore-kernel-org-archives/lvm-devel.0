From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 11:43:19 +0000 (UTC)
Subject: master - dmeventd: debug only subsystemd with # sign
Message-ID: <20161103114319.A855D60DB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd468b6218fc5c46e98ee0061010724c298c312c
Commit:        cd468b6218fc5c46e98ee0061010724c298c312c
Parent:        33dd1f7747ecb4e16fb807af6673592d1b0d4c3d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 3 12:01:01 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 12:43:09 2016 +0100

dmeventd: debug only subsystemd with # sign

Reword the logging logic and try to restore previous logging
behavior for 'standalone' running daemon while preserving
debuggable feautures it has gained.

So actual rules:

dmeventd without any '-d' option will syslog all messages
from dmeventd.c it dmeventd plugins.

log_notice()==log_verbose()
log_info()==log_very_verbose()
But to show also log_debug() used has to give '-ddd'.

When user specified '-d, -dd, -ddd, -dddd' it
will also enable tracing of messages from libdm & lib
executed code - which is mainly useful for testing
i.e.: 'dmeventd -fldddd'
---
 WHATS_NEW_DM                          |    1 +
 daemons/dmeventd/libdevmapper-event.c |   26 ++++++++++++++++++--------
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index fa77d10..73a5171 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Notice and Info messages are again logged from dmeventd and its plugins.
   Dmeventd now also respects DM_ABORT_ON_INTERNAL_ERRORS as libdm based tool.
   Report as non default dm logging also when logging with errno was changed.
   Use log_level() macro to consistently decode message log level in dmeventd.
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 12173fd..b23b6c1 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -872,22 +872,31 @@ void dm_event_log(const char *subsys, int level, const char *file,
 	FILE *stream = log_stderr(level) ? stderr : stdout;
 	int prio;
 	time_t now;
+	int log_with_debug = 0;
+
+	if (subsys[0] == '#') {
+		/* Subsystems starting with '#' are logged
+		 * only when debugging is enabled. */
+		log_with_debug++;
+		subsys++;
+	}
 
 	switch (log_level(level)) {
 	case _LOG_DEBUG:
+		/* Never shown without -ddd */
 		if (_debug_level < 3)
 			return;
 		prio = LOG_DEBUG;
 		indent = "      ";
 		break;
 	case _LOG_INFO:
-		if (_debug_level < 2)
+		if (log_with_debug && _debug_level < 2)
 			return;
 		prio = LOG_INFO;
 		indent = "    ";
 		break;
 	case _LOG_NOTICE:
-		if (_debug_level < 1)
+		if (log_with_debug && _debug_level < 1)
 			return;
 		prio = LOG_NOTICE;
 		indent = "  ";
@@ -913,12 +922,13 @@ void dm_event_log(const char *subsys, int level, const char *file,
 		if (!start)
 			start = now;
 		now -= start;
-		fprintf(stream, "[%2d:%02d] %8x:%-6s%s",
-			(int)now / 60, (int)now % 60,
-			// TODO: Maybe use shorter ID
-			// ((int)(pthread_self()) >> 6) & 0xffff,
-			(int)pthread_self(), subsys,
-			(_debug_level > 3) ? "" : indent);
+		if (_debug_level)
+			fprintf(stream, "[%2d:%02d] %8x:%-6s%s",
+				(int)now / 60, (int)now % 60,
+				// TODO: Maybe use shorter ID
+				// ((int)(pthread_self()) >> 6) & 0xffff,
+				(int)pthread_self(), subsys,
+				(_debug_level > 3) ? "" : indent);
 		if (_debug_level > 3)
 			fprintf(stream, "%28s:%4d %s", file, line, indent);
 		vfprintf(stream, _(format), ap);


