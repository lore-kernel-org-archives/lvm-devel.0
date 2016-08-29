From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 29 Aug 2016 19:08:59 +0000 (UTC)
Subject: master - cleanup: clean gcc6 minor/major types warnings
Message-ID: <20160829190859.9C53061817@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92d5a8441007f578e000b492cecf67d6b8a87405
Commit:        92d5a8441007f578e000b492cecf67d6b8a87405
Parent:        81970d22d8a841c1ea69fde5c9108fc4df3759bd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 18 14:41:46 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 29 20:51:16 2016 +0200

cleanup: clean gcc6 minor/major types warnings

Put sys/sysmacros.h in front of sys/types.h header file as requested
by gcc6.
---
 lib/filters/filter-sysfs.c |    1 +
 libdm/libdm-stats.c        |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index 3115f86..6f566bc 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -17,6 +17,7 @@
 
 #ifdef __linux__
 
+#include <sys/sysmacros.h>
 #include <dirent.h>
 
 static int _locate_sysfs_blocks(const char *sysfs_dir, char *path, size_t len,
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 1c2e19b..6932b28 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -19,6 +19,7 @@
 
 #include "math.h" /* log10() */
 
+#include <sys/sysmacros.h>
 #include <sys/ioctl.h>
 #include <sys/vfs.h> /* fstatfs */
 


