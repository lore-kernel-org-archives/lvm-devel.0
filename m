From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  1 Apr 2014 13:27:07 +0000 (UTC)
Subject: master - lvm-wrappers: Remove spurious #include <libudev.h>.
Message-ID: <20140401132707.9EBFC60E06@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5682ccbaca1e6c405494b2b84417131c7b034f5
Commit:        d5682ccbaca1e6c405494b2b84417131c7b034f5
Parent:        490226fc475232e0b158cf9fdc8670a663da4efe
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Apr 1 15:17:50 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Apr 1 15:26:26 2014 +0200

lvm-wrappers: Remove spurious #include <libudev.h>.

---
 lib/device/dev-cache.c  |    3 +++
 lib/misc/lvm-wrappers.c |    2 ++
 lib/misc/lvm-wrappers.h |    2 +-
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 94052dc..b16ace4 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -19,6 +19,9 @@
 #include "config.h"
 #include "toolcontext.h"
 
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+#endif
 #include <unistd.h>
 #include <sys/param.h>
 #include <dirent.h>
diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index 46590b9..7ea3ac5 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -18,6 +18,8 @@
 #include <fcntl.h>
 
 #ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+
 struct udev *_udev;
 
 int udev_init_library_context(void)
diff --git a/lib/misc/lvm-wrappers.h b/lib/misc/lvm-wrappers.h
index e43f831..b8d1217 100644
--- a/lib/misc/lvm-wrappers.h
+++ b/lib/misc/lvm-wrappers.h
@@ -17,7 +17,7 @@
 #define _LVM_WRAPPERS_H
 
 #ifdef UDEV_SYNC_SUPPORT
-#include <libudev.h>
+struct udev;
 struct udev *udev_get_library_context(void);
 #endif
 


