From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon,  6 Jul 2015 15:21:17 +0000 (UTC)
Subject: master - clean-up: typos s/bellow/below/
Message-ID: <20150706152117.2E577603D5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4daea88516e39083ba52d6804c0cd398c899505d
Commit:        4daea88516e39083ba52d6804c0cd398c899505d
Parent:        810ab095e6709364d9f7c86d3754762aab3d976d
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jul 6 10:15:11 2015 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jul 6 10:15:11 2015 -0500

clean-up: typos s/bellow/below/

---
 lib/metadata/thin_manip.c                |    2 +-
 lib/misc/lvm-signal.c                    |    2 +-
 libdm/libdevmapper.h                     |    2 +-
 test/shell/lvextend-snapshot-dmeventd.sh |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index dd4e514..181c72e 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -313,7 +313,7 @@ int pool_check_overprovisioning(const struct logical_volume *lv)
 			 txt,
 			 (sz > 0) ? display_size(cmd, sz) : "no free space in volume group");
 		if (max_threshold > 99)
-			log_print_unless_silent("For thin pool auto extension activation/thin_pool_autoextend_threshold should be bellow 100.");
+			log_print_unless_silent("For thin pool auto extension activation/thin_pool_autoextend_threshold should be below 100.");
 		if (!min_percent)
 			log_print_unless_silent("For thin pool auto extension activation/thin_pool_autoextend_percent should be above 0.");
 	}
diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index d5dac6f..0d61e73 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -95,7 +95,7 @@ void sigint_restore(void)
 	    --_handler_installed >= MAX_SIGINTS)
 		return;
 
-	/* Nesting count went bellow MAX_SIGINTS. */
+	/* Nesting count went below MAX_SIGINTS. */
 	if (_oldmasked[_handler_installed]) {
 		sigset_t sigs;
 		sigprocmask(0, NULL, &sigs);
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 4ce2e6b..aad2971 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -734,7 +734,7 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 				 uint64_t flags);
 
 /*
- * Defines bellow are based on kernel's dm-cache.c defines
+ * Defines below are based on kernel's dm-cache.c defines
  * DM_CACHE_MIN_DATA_BLOCK_SIZE (32 * 1024 >> SECTOR_SHIFT)
  * DM_CACHE_MAX_DATA_BLOCK_SIZE (1024 * 1024 * 1024 >> SECTOR_SHIFT)
  */
diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index 1ad4864..aeb18f1 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -50,7 +50,7 @@ write_ 1000 1700
 pre=$(percent_)
 # Normally the usage should be ~66% here, however on slower systems
 # dmeventd could be actually 'fast' enough to have COW already resized now
-# so mark test skipped if we are bellow 50% by now
+# so mark test skipped if we are below 50% by now
 test $pre -gt 50 || skip
 wait_for_change_ $pre
 test $pre -gt $(percent_)


