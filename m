From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  6 Oct 2014 21:23:27 +0000 (UTC)
Subject: master - man: lvmcache mention automatic pool conversion
Message-ID: <20141006212327.E480160F2B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31f10a05544122693143da75bb4a4857cb890226
Commit:        31f10a05544122693143da75bb4a4857cb890226
Parent:        97b16ec26f10f98b7febf661ba33bcd2882c7e6c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 6 16:12:51 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 6 16:22:54 2014 -0500

man: lvmcache mention automatic pool conversion

When converting an origin to a cache lv, lvm will automatically convert
the specified cache pool into a cache pool if it is not already a cache
pool.
---
 man/lvmcache.7.in |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 2603e1a..79ceb64 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -276,6 +276,7 @@ the same VG.
 .br
 .B lvconvert --type cache\-pool VG/CacheDataLV
 
+
 .SS Create a new cache LV without an existing origin LV
 
 \&
@@ -286,7 +287,7 @@ single step.
 
 .B lvcreate \-\-type cache \-L LargeSize \-n CacheLV
 .RS
-.B \-\-cachepool VG/CachePoolLV SlowPVs
+.B \-\-cachepool VG/CachePoolLV VG SlowPVs
 .RE
 
 
@@ -301,6 +302,32 @@ LV, a cache metadata LV, and combines the two into a cache pool LV.
 .B lvcreate \-\-type cache\-pool \-L CacheSize \-n CachePoolLV VG FastPVs
 
 
+.SS Convert existing LVs to cache types
+
+\&
+
+When an existing origin LV is converted to a cache LV, the specified cache
+pool may be a normal LV, rather than a cache pool LV.  In this case, lvm
+will first convert the normal LV to a cache pool LV.  A pool metadata LV
+may optionally be specified.
+
+.B lvcreate -n OriginLV -L LargeSize VG
+.br
+.B lvcreate -n CacheDataLV -L CacheSize VG
+.br
+.B lvconvert --type cache --cachepool VG/CataDataLV VG/OriginLV
+
+This is equivalent to:
+
+.B lvcreate -n OriginLV -L LargeSize VG
+.br
+.B lvcreate -n CacheDataLV -L CacheSize VG
+.br
+.B lvconvert --type cache-pool VG/CacheDataLV
+.br
+.B lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
+
+
 .SH SEE ALSO
 .BR lvm.conf (5),
 .BR lvchange (8),


