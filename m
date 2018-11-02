From: David Teigland <teigland@sourceware.org>
Date: Fri, 2 Nov 2018 16:59:43 -0400
Subject: master - lvmlockd: use standard major minor functions
Message-ID: <201811022059.wA2KxhE9025617@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5d747f724eb915007fa5d9bbe6539be3cd12d730
Commit:        5d747f724eb915007fa5d9bbe6539be3cd12d730
Parent:        e7a56d5cd32654e4921e4c03bc434efd0e24b1c0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 2 15:58:47 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 2 15:58:47 2018 -0500

lvmlockd: use standard major minor functions

---
 daemons/lvmlockd/lvmlockd-sanlock.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 9c950f3..d22d009 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -44,7 +44,7 @@
 #include <errno.h>
 #include <syslog.h>
 #include <blkid/blkid.h>
-#include <linux/kdev_t.h>
+#include <sys/sysmacros.h>
 
 #define ONE_MB 1048576
 
@@ -351,7 +351,7 @@ static void _read_sysfs_size(dev_t devno, const char *name, unsigned int *val)
 	size_t len;
 
 	snprintf(path, sizeof(path), "/sys/dev/block/%d:%d/queue/%s",
-		 (int)MAJOR(devno), (int)MINOR(devno), name);
+		 (int)major(devno), (int)minor(devno), name);
 
 	if (!(fp = fopen(path, "r")))
 		return;


