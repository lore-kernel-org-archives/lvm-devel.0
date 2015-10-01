From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  1 Oct 2015 19:43:37 +0000 (UTC)
Subject: master - man lvmcache: updates for mode and policy
Message-ID: <20151001194337.B364260D51@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e5d48348b0c7afdd7a3fb56ddd6875a8b81dc68
Commit:        5e5d48348b0c7afdd7a3fb56ddd6875a8b81dc68
Parent:        26da6a3e10d2b8a84326288b53c8e9a6d82a3846
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 1 11:39:07 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 1 14:23:39 2015 -0500

man lvmcache: updates for mode and policy

Correct some things, e.g. set mode and policy on
the cache lv, not the pool, lvm.conf field for
mode changed.

Add smq which was missing.

Make the sections on cache mode and cache policy
consistent in structure and style.
---
 man/lvmcache.7.in |   74 ++++++++++++++++++++++++++++++-----------------------
 1 files changed, 42 insertions(+), 32 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 7257386..44709d1 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -195,6 +195,7 @@ Users who are concerned about the possibility of failures in their fast
 devices that could lead to data loss might consider making their cache
 pool sub-LVs redundant.
 
+.I Example
 .nf
 0. Create an origin LV we wish to cache
 # lvcreate \-L 10G \-n lv1 vg /dev/slow_devs
@@ -228,14 +229,18 @@ from the cache pool back to the origin LV.  This mode will increase
 performance, but the loss of a device associated with the cache pool LV
 can result in lost data.
 
-The cache mode can be specified with the --cachemode option when a cache
-pool LV is created.
+With the \-\-cachemode option, the cache mode can be set when creating a
+cache LV, or changed on an existing cache LV.  The current cache mode of a
+cache LV can be displayed with the cache_mode reporting option:
+
+.B lvs \-o+cache_mode VG/CacheLV
 
 .BR lvm.conf (5)
-.B cache_pool_cachemode
+.B allocation/cache_mode
 .br
 defines the default cache mode.
 
+.I Example
 .nf
 0. Create an origin LV we wish to cache (yours may already exist)
 # lvcreate \-L 10G \-n lv1 vg /dev/slow
@@ -246,50 +251,55 @@ defines the default cache mode.
 2. Create a cache metadata LV
 # lvcreate \-L 8M \-n cache1meta vg /dev/fast
 
-3. Create a cache pool LV specifying cache mode "writethrough"
-# lvconvert \-\-type cache\-pool \-\-poolmetadata vg/cache1meta \\
-	\-\-cachemode writethrough vg/cache1
+3. Create a cache pool LV
+# lvconvert \-\-type cache\-pool \-\-poolmetadata vg/cache1meta vg/cache1
 
-4. Create a cache LV by combining the cache pool LV and origin LV
-# lvconvert \-\-type cache \-\-cachepool vg/cache1 vg/lv1
+4. Create a cache LV by combining the cache pool LV and origin LV,
+   and use the writethrough cache mode.
+# lvconvert \-\-type cache \-\-cachepool vg/cache1 \\
+	\-\-cachemode writethrough vg/lv1
 .fi
 
-The cache mode can be changed on an existing LV with the command:
 
-.B lvconvert --cachemode writethrough|writeback VG/CacheLV
+.SS Cache policy
 
+\&
 
-.SS Cache policy & policy settings
+The cache subsystem has additional per-LV parameters: the cache policy to
+use, and possibly tunable parameters for the cache policy.  Three policies
+are currently available: "smq" is the default policy, "mq" is an older
+implementation, and "cleaner" is used to force the cache to write back
+(flush) all cached writes to the origin LV.
 
-\&
+The "mq" policy has a number of tunable parameters. The defaults are
+chosen to be suitable for the majority of systems, but in special
+circumstances, changing the settings can improve performance.
 
-The cache subsystem has an additional per-LV parameter, namely the cache policy
-to use, and possibly the tunable parameters of the said cache policy. In the
-current implementation, two policies are available, "mq" which is the default
-policy and "cleaner" which is used to force the cache to write back (flush) all
-cached writes to the origin LV. Moreover, the "mq" policy has a number of
-tunable parameters: the defaults are chosen to be suitable for the vast
-majority of systems. However, under special circumstances, changing the tunable
-settings of the cache policy can improve performance.
+With the \-\-cachepolicy and \-\-cachesettings options, the cache policy
+and settings can be set when creating a cache LV, or changed on an
+existing cache LV (both options can be used together).  The current cache
+policy and settings of a cache LV can be displayed with the cache_policy
+and cache_settings reporting options:
 
-On an existing cache LV, the policy can be set (to "mq") and the cache settings
-can be changed using commands like these:
+.B lvs \-o+cache_policy,cache_settings VG/CacheLV
 
 .I Example
-
 .nf
-# lvchange \-\-cachepolicy mq vg/lv1
-# lvchange \-\-cachesettings \(aqmigration_threshold=2048 random_threshold=4\(aq \\
-     vg/lv1
+Change the cache policy and settings of an existing cache LV.
+# lvchange \-\-cachepolicy mq \-\-cachesettings \\
+	\(aqmigration_threshold=2048 random_threshold=4\(aq vg/lv1
 .fi
 
-Both commands can be combined, setting both cache policy and its settings
-together. Moreover, when creating a cache LV for the first time (using
-lvcreate), the \-\-cachepolicy and \-\-cachesettings parameters can be used as
-well. The current policy and the policy settings can be listed using the lvs
-command, using 'cache_policy' and 'cache_settings' fields:
+.BR lvm.conf (5)
+.B allocation/cache_policy
+.br
+defines the default cache policy.
+
+.BR lvm.conf (5)
+.B allocation/cache_settings
+.br
+defines the default cache settings.
 
-# lvs -o +cache_policy,cache_settings
 
 .SS Spare metadata LV
 


