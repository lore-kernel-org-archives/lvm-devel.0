From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:59 +0000 (UTC)
Subject: master - cleanup: do include lvm headers in libdm build
Message-ID: <20140408090259.E6A88606F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4d8060ff42ed25886eda71122513873a25a3f12
Commit:        d4d8060ff42ed25886eda71122513873a25a3f12
Parent:        5553a099d1a6f0c8e3421712517d41ef820a5964
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 4 21:13:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:15 2014 +0200

cleanup: do include lvm headers in libdm build

Relocate some defines from lvm headers to those
few shared between libdm and lib code.
---
 lib/datastruct/lvm-types.h |    5 -----
 lib/misc/lib.h             |   11 ++++++++---
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/datastruct/lvm-types.h b/lib/datastruct/lvm-types.h
index e96009d..de144bd 100644
--- a/lib/datastruct/lvm-types.h
+++ b/lib/datastruct/lvm-types.h
@@ -21,11 +21,6 @@
 
 #include "libdevmapper.h"
 
-/* Define some portable printing types */
-#define PRIsize_t "zu"
-#define PRIptrdiff_t "td"
-#define PRIpid_t PRId32
-
 struct str_list {
 	struct dm_list list;
 	const char *str;
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index 100827d..f0dba25 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -25,17 +25,22 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
+/* Define some portable printing types */
+#define PRIsize_t "zu"
+#define PRIptrdiff_t "td"
+#define PRIpid_t PRId32
+
 #include "intl.h"
 #include "libdevmapper.h"
-#include "lvm-globals.h"
-#include "lvm-wrappers.h"
-#include "lvm-types.h"
 #include "util.h"
 
 #ifdef DM
 #  include "dm-logging.h"
 #else
 #  include "lvm-logging.h"
+#  include "lvm-globals.h"
+#  include "lvm-wrappers.h"
+#  include "lvm-types.h"
 #endif
 
 #include <errno.h>


