From: David Teigland <teigland@sourceware.org>
Date: Wed,  2 Dec 2020 21:30:06 +0000 (GMT)
Subject: main - man lvmcache: add writecache cleaner info
Message-ID: <20201202213006.84C8E395C03A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b3458d5a945302a68e4f5ed3011f01677411e9b
Commit:        9b3458d5a945302a68e4f5ed3011f01677411e9b
Parent:        a2affffed558899af563b790eaf5112b8c7e5bd5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 2 15:29:21 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 2 15:29:21 2020 -0600

man lvmcache: add writecache cleaner info

---
 man/lvmcache.7_main | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 37d0e3359..85d4d9e34 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -303,6 +303,16 @@ afterwards.  Some underlying devices perform better with fua, some with
 nofua.  Testing is necessary to determine which.
 Applicable only to persistent memory.
 
+.IP \[bu] 2
+cleaner = 0|1
+
+Setting cleaner=1 enables the writecache cleaner mode in which data is
+gradually flushed from the cache.  If this is done prior to detaching the
+writecache, then the splitcache command will have little or no flushing to
+perform.  If not done beforehand, the splitcache command enables the
+cleaner mode and waits for flushing to complete before detaching the
+writecache.  Adding cleaner=0 to the splitcache command will skip the
+cleaner mode, and any required flushing is performed in device suspend.
 
 .SS dm-cache with separate data and metadata LVs
 


