From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:17 +0000 (UTC)
Subject: master - cleanup: include stdarg.h where needed.
Message-ID: <20140418145517.01E6A60F54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=589983a257cd2f92489f41d2d7ec62784bf357e7
Commit:        589983a257cd2f92489f41d2d7ec62784bf357e7
Parent:        b7741f0a831ef9dfd4fda19abba6ca8e91baa378
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 15 13:27:47 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:50 2014 +0200

cleanup: include stdarg.h where needed.

Avoid dependency on implicit inclusion of stdarg.h with
libdevmapper.h.
---
 daemons/clvmd/clvmd.c                              |    9 +++++----
 daemons/dmeventd/dmeventd.c                        |    1 +
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |    1 +
 lib/display/display.c                              |    1 +
 lib/misc/lvm-string.c                              |    1 +
 libdm/libdm-config.c                               |    1 +
 libdm/libdm-string.c                               |    1 +
 8 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 3e92490..9b865f6 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -19,10 +19,6 @@
 
 #include "clvmd-common.h"
 
-#include <pthread.h>
-#include <getopt.h>
-#include <ctype.h>
-
 #include "clvmd-comms.h"
 #include "clvm.h"
 #include "clvmd.h"
@@ -34,6 +30,11 @@
 #include <corosync/confdb.h>
 #endif
 
+#include <pthread.h>
+#include <getopt.h>
+#include <ctype.h>
+#include <stdarg.h>
+
 #include <fcntl.h>
 #include <netinet/in.h>
 #include <signal.h>
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 906f731..32610ec 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -26,6 +26,7 @@
 //#include "libmultilog.h"
 #include "dm-logging.h"
 
+#include <stdarg.h>
 #include <dlfcn.h>
 #include <errno.h>
 #include <pthread.h>
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index c4b69e2..bbee93a 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -20,6 +20,7 @@
 
 #include <sys/wait.h>
 #include <syslog.h> /* FIXME Replace syslog with multilog */
+#include <stdarg.h>
 /* FIXME Missing openlog? */
 
 /* First warning when snapshot is 80% full. */
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index b700b8d..f0d3f24 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -20,6 +20,7 @@
 
 #include <sys/wait.h>
 #include <syslog.h> /* FIXME Replace syslog with multilog */
+#include <stdarg.h>
 /* FIXME Missing openlog? */
 
 /* First warning when thin is 80% full. */
diff --git a/lib/display/display.c b/lib/display/display.c
index 3bcf439..b7fbf1a 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -22,6 +22,7 @@
 #include "defaults.h"
 #include <math.h>  /* fabs() */
 #include <float.h> /* DBL_EPSILON */
+#include <stdarg.h>
 
 #define SIZE_BUF 128
 
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 5377528..cdee02b 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -18,6 +18,7 @@
 #include "metadata-exported.h"
 
 #include <ctype.h>
+#include <stdarg.h>
 
 int emit_to_buffer(char **buffer, size_t *size, const char *fmt, ...)
 {
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index ea1af2f..f8d6b1b 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -20,6 +20,7 @@
 #include <unistd.h>
 #include <fcntl.h>
 #include <ctype.h>
+#include <stdarg.h>
 
 #define SECTION_B_CHAR '{'
 #define SECTION_E_CHAR '}'
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 9d667bb..64a9792 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -15,6 +15,7 @@
 #include "dmlib.h"
 
 #include <ctype.h>
+#include <stdarg.h>
 
 /*
  * consume characters while they match the predicate function.


