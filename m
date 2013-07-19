From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 19 Jul 2013 15:02:00 +0000 (UTC)
Subject: master - RAID: Fix segfault when reporting raid_syncaction field on older kernel
Message-ID: <20130719150200.6993960DEF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4eea66019157abd992c8802564b675fd97420c01
Commit:        4eea66019157abd992c8802564b675fd97420c01
Parent:        f0ab6c33a9475502ea8af1cf54addba68f97428f
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Jul 19 10:01:48 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Jul 19 10:01:48 2013 -0500

RAID: Fix segfault when reporting raid_syncaction field on older kernel

The status printed for dm-raid targets on older kernels does not include
the syncaction field.  This is handled by dev_manager_raid_status() just
fine by populating the raid status structure with NULL for that field.
However, lv_raid_sync_action() does not properly handle that field being
NULL.  So, check for it and return 0 if it is NULL.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0b96df0..46d7d23 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix segfault when reporting raid_syncaction for older kernels.
   Add LV reporting fields raid_mismatch_count, raid_sync_action, raid_write_behind.
   Add LV reporting fields raid_min_recovery_rate, raid_max_recovery_rate.
   Add sync_percent as alias for copy_percent LV reporting field.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 204cceb..61dbc02 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -874,7 +874,9 @@ int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action)
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
+	/* status->sync_action can be NULL if dm-raid version < 1.5.0 */
 	if (!dev_manager_raid_status(dm, lv, &status) ||
+	    !status->sync_action ||
 	    !(action = dm_pool_strdup(lv->vg->cmd->mem,
 				      status->sync_action))) {
 		dev_manager_destroy(dm);


