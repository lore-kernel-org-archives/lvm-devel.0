From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 19 Aug 2009 11:22:16 -0400
Subject: [PATCH] lvm2: fix SIGSEGV of dmeventd
Message-ID: <4A8C18A8.7030307@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Around July 16th, 2009, the prototype of logging function was changed and
dm_errno was added as the forth argument. However plugin functions stay
unchanged and dmeventd is killed by the signal (SIGSEGV). This patch adds
the argument, dm_errno, in the plugin functions.

-- 
Takahiro Yasui
Hitachi Computer Products (America), Inc.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c     |    1 +
 daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c |    1 +
 tools/lvm2cmd.h                                       |    2 +-
 3 files changed, 3 insertions(+), 1 deletion(-)

Index: LVM2.02.52-20090818/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
===================================================================
--- LVM2.02.52-20090818.orig/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ LVM2.02.52-20090818/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -128,6 +128,7 @@ out_parse:
 
 static void _temporary_log_fn(int level, const char *file __attribute((unused)),
 			      int line __attribute((unused)),
+			      int dm_errno __attribute((unused)),
 			      const char *format)
 {
 	if (!strncmp(format, "WARNING: ", 9) && (level < 5))
Index: LVM2.02.52-20090818/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
===================================================================
--- LVM2.02.52-20090818.orig/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ LVM2.02.52-20090818/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -57,6 +57,7 @@ static pthread_mutex_t _event_mutex = PT
 static void _temporary_log_fn(int level,
 			      const char *file __attribute((unused)),
 			      int line __attribute((unused)),
+			      int dm_errno __attribute((unused)),
 			      const char *format)
 {
 	if (!strncmp(format, "WARNING: ", 9) && (level < 5))
Index: LVM2.02.52-20090818/tools/lvm2cmd.h
===================================================================
--- LVM2.02.52-20090818.orig/tools/lvm2cmd.h
+++ LVM2.02.52-20090818/tools/lvm2cmd.h
@@ -18,7 +18,7 @@
 
 #ifndef _LVM_LOG_H
 typedef void (*lvm2_log_fn_t) (int level, const char *file, int line,
-			       const char *message);
+			       int dm_errno, const char *message);
 #endif
 
 #define LVM2_LOG_SUPPRESS	0


