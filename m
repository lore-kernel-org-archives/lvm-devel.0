From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Feb 2015 13:44:35 +0000 (UTC)
Subject: master - cleanup: drop unused header file
Message-ID: <20150219134435.DA08E60057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af395e61d52af330f5927f5dbf528c995574ee45
Commit:        af395e61d52af330f5927f5dbf528c995574ee45
Parent:        a18d789684e0fd1864e419b4ee8ba97c3a37030f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 19 14:42:27 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 19 14:44:04 2015 +0100

cleanup: drop unused header file

---
 lib/filters/filter-partitioned.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index 2c21452..9ca8f6f 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -15,9 +15,6 @@
 
 #include "lib.h"
 #include "filter.h"
-#ifdef UDEV_SYNC_SUPPORT
-#include <libudev.h>
-#endif
 
 static int _passes_partitioned_filter(struct dev_filter *f, struct device *dev)
 {


