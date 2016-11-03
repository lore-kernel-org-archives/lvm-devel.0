From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 11:43:17 +0000 (UTC)
Subject: master - dmeventd: abort on internal error
Message-ID: <20161103114317.7812360DB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=33dd1f7747ecb4e16fb807af6673592d1b0d4c3d
Commit:        33dd1f7747ecb4e16fb807af6673592d1b0d4c3d
Parent:        e50d434a353efac7d4947c7deeaf7cfd773ea6e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 2 14:40:12 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 12:43:09 2016 +0100

dmeventd: abort on internal error

Provide same support for DM_ABORT_ON_INTERNAL_ERRORS we do have
with default libdm logging  as  dmeventd is libdm based tool.
---
 WHATS_NEW_DM                          |    1 +
 daemons/dmeventd/libdevmapper-event.c |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8cf0e05..fa77d10 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Dmeventd now also respects DM_ABORT_ON_INTERNAL_ERRORS as libdm based tool.
   Report as non default dm logging also when logging with errno was changed.
   Use log_level() macro to consistently decode message log level in dmeventd.
   Still produce output when dmsetup dependency tree building finds dev missing.
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 8c21537..12173fd 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -865,6 +865,7 @@ void dm_event_log(const char *subsys, int level, const char *file,
 		  int line, int dm_errno_or_class,
 		  const char *format, va_list ap)
 {
+	static int _abort_on_internal_errors = -1;
 	static pthread_mutex_t _log_mutex = PTHREAD_MUTEX_INITIALIZER;
 	static time_t start = 0;
 	const char *indent = "";
@@ -926,6 +927,15 @@ void dm_event_log(const char *subsys, int level, const char *file,
 	}
 
 	pthread_mutex_unlock(&_log_mutex);
+
+	if (_abort_on_internal_errors < 0)
+		/* Set when env DM_ABORT_ON_INTERNAL_ERRORS is not "0" */
+		_abort_on_internal_errors =
+			strcmp(getenv("DM_ABORT_ON_INTERNAL_ERRORS") ? : "0", "0");
+
+	if (_abort_on_internal_errors &&
+	    !strncmp(format, INTERNAL_ERROR, sizeof(INTERNAL_ERROR) - 1))
+		abort();
 }
 
 #if 0				/* left out for now */


