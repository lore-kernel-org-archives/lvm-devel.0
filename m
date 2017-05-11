From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 May 2017 11:53:29 -0400
Subject: master - man lvmcache: add info about metadata formats
Message-ID: <201705111553.v4BFrT0v011697@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d49a20b7bdc9b741def219be897c5057db5e05ff
Commit:        d49a20b7bdc9b741def219be897c5057db5e05ff
Parent:        80900dcf76d2c91d8892e54913367bfed1012056
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 11 10:52:59 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 11 10:52:59 2017 -0500

man lvmcache: add info about metadata formats

---
 man/lvmcache.7_main |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index e573b58..1f29185 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -404,6 +404,24 @@ This is equivalent to:
 .B lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
 
 
+.SS Cache metadata formats
+
+\&
+
+There are two disk formats for cache metadata.  The metadata format can be
+specified when a cache pool is created, and cannot be changed.
+Format \fB2\fP has better performance; it is more compact, and stores
+dirty bits in a separate btree, which improves the speed of shutting down
+the cache.
+With \fBauto\fP, lvm selects the best option provided by the current
+dm-cache kernel target.
+
+.B lvconvert --type cache-pool --cachemetadataformat auto|1|2
+.RS
+.B VG/CacheDataLV
+.RE
+
+
 .SH SEE ALSO
 .BR lvm.conf (5),
 .BR lvchange (8),


