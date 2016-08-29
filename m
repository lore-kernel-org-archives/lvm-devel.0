From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 29 Aug 2016 19:08:57 +0000 (UTC)
Subject: master - cache: do not monitor cache-pool
Message-ID: <20160829190857.79603618A7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81970d22d8a841c1ea69fde5c9108fc4df3759bd
Commit:        81970d22d8a841c1ea69fde5c9108fc4df3759bd
Parent:        b493811968b34876ef558ad04d18c1b76bd28113
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 24 10:05:09 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 29 20:51:15 2016 +0200

cache: do not monitor cache-pool

Avoid monitoring of activated cache-pool - where the only purpose ATM
is to clear metadata volume which is actually activate in place
of cache-pool name (using public LV name).

Since VG lock is held across whole clear operation, dmeventd cannot
be used anyway - however in case of appliction crash we may
leave unmonitored device.

In future we may provide better mechanism as the current name
replacemnet is creating 'uncommon' table setups in case the metadata
LV is more complex type like raid  (needs some futher thinking about
error path results).

Another point to think about is the fact we should not clear device
while holding lock (i.e. dmeventd mirror repair cannot work in cases
like this).
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 76e203d..6980e17 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Do not monitor cache-pool metadata when LV is just being cleared.
   Add allocation/cache_pool_max_chunks to prevent misuse of cache target.
   Give error not segfault in lvconvert --splitmirrors when PV lies outside LV.
   Fix typo in report/columns_as_rows config option name recognition (2.02.99).
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index f4d3a17..9977291 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1724,6 +1724,23 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		return 1;
 
 	/*
+	 * Activation of unused cache-pool activates metadata device as
+	 * a public LV  for clearing purpose.
+	 * FIXME:
+	 *  As VG lock is held across whole operation unmonitored volume
+	 *  is usually OK since dmeventd couldn't do anything.
+	 *  However in case command would have crashed, such LV is
+	 *  left unmonitored and may potentially require dmeventd.
+	 */
+	if ((lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) &&
+	    !lv_is_used_cache_pool((find_pool_seg(first_seg(lv))->lv))) {
+		log_debug_activation("Skipping %smonitor of %s.%s",
+				     (monitor) ? "" : "un", display_lvname(lv),
+				     (monitor) ? " Cache pool activation for clearing only." : "");
+		return 1;
+	}
+
+	/*
 	 * Allow to unmonitor thin pool via explicit pool unmonitor
 	 * or unmonitor before the last thin pool user deactivation
 	 * Skip unmonitor, if invoked via deactivation of thin volume


