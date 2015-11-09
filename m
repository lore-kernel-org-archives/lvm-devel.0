From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 16:05:52 +0000 (UTC)
Subject: master - cleanup: drop unneded headers
Message-ID: <20151109160552.ED4DF60D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3db5ba08b13fd542e725039646123bd8c0c5326a
Commit:        3db5ba08b13fd542e725039646123bd8c0c5326a
Parent:        6c331f3061269cc4a60e2b40f12f2dcb19a86994
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 16:37:05 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 17:04:10 2015 +0100

cleanup: drop unneded headers

Coverity notices they are not really needed.
---
 daemons/lvmlockd/lvmlockctl.c       |    1 -
 daemons/lvmlockd/lvmlockd-core.c    |    1 -
 daemons/lvmlockd/lvmlockd-dlm.c     |    3 ---
 daemons/lvmlockd/lvmlockd-sanlock.c |    3 ---
 4 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 2e1acd4..4f559cf 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -18,7 +18,6 @@
 #include <errno.h>
 #include <fcntl.h>
 #include <syslog.h>
-#include <sys/wait.h>
 #include <sys/socket.h>
 #include <sys/un.h>
 
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 6d5f579..49f408b 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -16,7 +16,6 @@
 
 #include "daemon-io.h"
 #include "daemon-server.h"
-#include "daemon-log.h"
 #include "lvm-version.h"
 #include "lvmetad-client.h"
 #include "lvmlockd-client.h"
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index acadf2d..2cf2c20 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -14,7 +14,6 @@
 #include "tool.h"
 
 #include "daemon-server.h"
-#include "daemon-log.h"
 #include "xlate.h"
 
 #include "lvmlockd-internal.h"
@@ -26,7 +25,6 @@
  */
 #include "libdlm.h"
 
-#include <pthread.h>
 #include <stddef.h>
 #include <poll.h>
 #include <errno.h>
@@ -35,7 +33,6 @@
 #include <byteswap.h>
 #include <syslog.h>
 #include <dirent.h>
-#include <sys/socket.h>
 
 struct lm_dlm {
 	dlm_lshandle_t *dh;
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index e1a85b4..7cdaf85 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -14,7 +14,6 @@
 #include "tool.h"
 
 #include "daemon-server.h"
-#include "daemon-log.h"
 #include "xlate.h"
 
 #include "lvmlockd-internal.h"
@@ -25,12 +24,10 @@
 #include "sanlock_admin.h"
 #include "sanlock_resource.h"
 
-#include <pthread.h>
 #include <stddef.h>
 #include <poll.h>
 #include <errno.h>
 #include <syslog.h>
-#include <sys/socket.h>
 
 /*
 -------------------------------------------------------------------------------


