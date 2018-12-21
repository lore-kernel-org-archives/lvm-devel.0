From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:46:37 -0500
Subject: master - scripts: simplify including for generator
Message-ID: <201812212046.wBLKkbT0021369@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0161ebe484005e948eab6b12bc3942e62a22819b
Commit:        0161ebe484005e948eab6b12bc3942e62a22819b
Parent:        a4577c427a76c6a337b7812f9da7700c2c8beb89
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 19:14:32 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:42:30 2018 +0100

scripts: simplify including for generator

Uses included .c file as primary header includer.
---
 scripts/generator-internals.c                      |    2 ++
 .../lvm2_activation_generator_systemd_red_hat.c    |   20 --------------------
 test/unit/activation-generator_t.c                 |    2 --
 3 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/scripts/generator-internals.c b/scripts/generator-internals.c
index 9619e8c..9919247 100644
--- a/scripts/generator-internals.c
+++ b/scripts/generator-internals.c
@@ -1,6 +1,8 @@
 // This file contains the unit testable parts of
 // lvm2_activation_generator_systemd_red_hat
 
+#include "device_mapper/all.h"
+
 #include <ctype.h>
 #include <errno.h>
 #include <fcntl.h>
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index b44c8f0..a3a3e88 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -12,29 +12,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */
 
-#include <ctype.h>
-#include <errno.h>
-#include <fcntl.h>
-#include <limits.h>		/* For PATH_MAX for musl libc */
-#include <stdarg.h>
-#include <stdbool.h>
-#include <stdio.h>
-#include <string.h>
-#include <syslog.h>
-#include <sys/stat.h>
-#include <sys/types.h>
-#include <sys/wait.h>
-#include <unistd.h>
-
-#include "configure.h"
-#include "device_mapper/all.h"
-
-//----------------------------------------------------------------
-
 // Code in this file gets included in the unit tests.
 #include "generator-internals.c"
 
-//----------------------------------------------------------------
 // Logging
 
 #define KMSG_DEV_PATH		"/dev/kmsg"
diff --git a/test/unit/activation-generator_t.c b/test/unit/activation-generator_t.c
index ef4946d..6aa115c 100644
--- a/test/unit/activation-generator_t.c
+++ b/test/unit/activation-generator_t.c
@@ -15,8 +15,6 @@
 #include "units.h"
 #include "scripts/generator-internals.c"
 
-#include "device_mapper/all.h"
-
 //----------------------------------------------------------------
 
 static void _error(const char *format, ...)


