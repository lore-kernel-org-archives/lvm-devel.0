From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  2 Oct 2014 17:03:53 +0000 (UTC)
Subject: master - man: lvmcache better cache mode info and other command variations
Message-ID: <20141002170353.7B2AC60E52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91198ac13e61c66b65884660410311ffc8b8c24e
Commit:        91198ac13e61c66b65884660410311ffc8b8c24e
Parent:        17ab39f7431fdad4c8a445bd1e78a288eeb64bc1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 26 16:40:47 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 2 12:01:58 2014 -0500

man: lvmcache better cache mode info and other command variations

---
 man/lvmcache.7.in |   49 ++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 42 insertions(+), 7 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 6d7109a..6339b91 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -214,16 +214,27 @@ pool sub-LVs redundant.
 # lvconvert \-\-type cache \-\-cachepool vg/cache1 vg/lv1
 .fi
 
-.SS Writethough caching
+.SS Cache mode
 
 \&
 
-Writethrough caching ensures that any data written will be stored both in
-the cache pool LV and on the origin LV.  The loss of a device associated
-with the cache pool LV in this case would not mean the loss of any data.
-When combining the cache data LV and the cache metadata LV to form the
-cache pool LV, properties of the cache can be specified - in this case,
-\fIwritethrough\fP vs. \fIwriteback\fP.
+The default cache mode is "writethrough".  Writethrough ensures that any
+data written will be stored both in the cache pool LV and on the origin
+LV.  The loss of a device associated with the cache pool LV in this case
+would not mean the loss of any data.
+
+A second cache mode is "writeback".  Writeback delays writing data blocks
+from the cache pool back to the origin LV.  This mode will increase
+performance, but the loss of a device associated with the cache pool LV
+can result in lost data.
+
+The cache mode can be specified with the --cachemode option when a cache
+pool LV is created.
+
+.BR lvm.conf (5)
+.B cache_pool_cachemode
+.br
+defines the default cache mode.
 
 .nf
 0. Create an origin LV we wish to cache (yours may already exist)
@@ -264,6 +275,30 @@ the same VG.
 .br
 .B lvconvert --type cache\-pool VG/CacheDataLV
 
+.SS Create a new cache LV without an existing origin LV
+
+\&
+
+A cache LV can be created using an existing cache pool without an existing
+origin LV.  A new origin LV is created and linked to the cache pool in a
+single step.
+
+.B lvcreate \-\-type cache \-L LargeSize \-n CacheLV
+.RS
+.B \-\-cachepool VG/CachePoolLV SlowPVs
+.RE
+
+
+.SS Single step cache pool LV creation
+
+\&
+
+A cache pool LV can be created with a single lvcreate command, rather than
+using lvconvert on existing LVs.  This one command creates a cache data
+LV, a cache metadata LV, and combines the two into a cache pool LV.
+
+.B lvcreate \-\-type cache\-pool \-L CacheSize \-n CachePoolLV VG FastPVs
+
 
 .SH SEE ALSO
 .BR lvm.conf (5),


