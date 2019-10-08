From: David Teigland <teigland@sourceware.org>
Date: Tue, 8 Oct 2019 11:00:23 -0400
Subject: master - man: lvmcache note dm-cache block size issue
Message-ID: <201910081500.x98F0NU5002902@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=53b97b146df4de99207c580c1304d016832e318b
Commit:        53b97b146df4de99207c580c1304d016832e318b
Parent:        b6240c91882a98df9eceab0312eec893b7051765
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 8 09:59:38 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 8 09:59:38 2019 -0500

man: lvmcache note dm-cache block size issue

---
 man/lvmcache.7_main |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 9f3e526..0eefc89 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -140,6 +140,21 @@ metadata.)  This can be used with dm-cache.
 
 \&
 
+.SS dm-cache block size
+
+\&
+
+A cache pool will have a logical block size of 4096 bytes if it is created
+on a device with a logical block size of 4096 bytes.
+
+If a main LV has logical block size 512 (with an existing xfs file system
+using that size), then it cannot use a cache pool with a 4096 logical
+block size.  If the cache pool is attached, the main LV will likely fail
+to mount.
+
+To avoid this problem, use a mkfs option to specify a 4096 block size for
+the file system, or attach the cache pool before running mkfs.
+
 .SS dm-writecache block size
 
 \&


