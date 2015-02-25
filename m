From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 25 Feb 2015 17:33:56 +0000 (UTC)
Subject: master - lvmcache.7: add a section on --cachepolicy/--cachesettings
Message-ID: <20150225173356.7E28061054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d313282f2f824e321c5a78bec2ab0c5cc37f2d1
Commit:        0d313282f2f824e321c5a78bec2ab0c5cc37f2d1
Parent:        aa30e95271734d213440dd1150e2bdc7c9f4f171
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Feb 25 18:20:06 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Feb 25 18:21:30 2015 +0100

lvmcache.7: add a section on --cachepolicy/--cachesettings

---
 man/lvmcache.7.in |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 24ce5b4..c77633a 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -254,6 +254,38 @@ defines the default cache mode.
 # lvconvert \-\-type cache \-\-cachepool vg/cache1 vg/lv1
 .fi
 
+.SS Cache policy & policy settings
+
+\&
+
+The cache subsystem has an additional per-LV parameter, namely the cache policy
+to use, and possibly the tunable parameters of the said cache policy. In the
+current implementation, two policies are available, "mq" which is the default
+policy and "cleaner" which is used to force the cache to write back (flush) all
+cached writes to the origin LV. Moreover, the "mq" policy has a number of
+tunable parameters: the defaults are chosen to be suitable for the vast
+majority of systems. However, under special circumstances, changing the tunable
+settings of the cache policy can improve performance.
+
+On an existing cache LV, the policy can be set (to "mq") and the cache settings
+can be changed using commands like these:
+
+.I Example
+
+.nf
+# lvchange \-\-cachepolicy mq vg/lv1
+# lvchange \-\-cachesettings 'migration_threshold=2048 random_threshold=4' \\
+     vg/lv1
+.fi
+
+Both commands can be combined, setting both cache policy and its settings
+together. Moreover, when creating a cache LV for the first time (using
+lvcreate), the \-\-cachepolicy and \-\-cachesettings parameters can be used as
+well. The current policy and the policy settings can be listed using the lvs
+command, using 'cache_policy' and 'cache_settings' fields:
+
+# lvs -o +cache_policy,cache_settings
+
 .SS Spare metadata LV
 
 \&


