From: Milan Broz <mbroz@redhat.com>
Date: Mon, 15 Mar 2010 14:14:08 +0100
Subject: [PATCH] Fix pvcreate device check.
Message-ID: <1268658848-24437-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If user try to vgcreate or vgextend non-existent VG,
these messages appears:

# vgcreate xxx /dev/xxx
  Internal error: Volume Group xxx was not unlocked
  Device /dev/xxx not found (or ignored by filtering).
  Unable to add physical volume '/dev/xxx' to volume group 'xxx'.
  Internal error: Attempt to unlock unlocked VG xxx.

(the same with existing VG and non-existing PV & vgextend)
# vgextend vg_test /dev/xxx
...

It is caused because code tries to "refresh" cache if
md filter is switched on using cache destroy.

But we can change filters and rescan even without this
machinery now, just use refresh_filters
(and reset md filter afterwards).

(Patch also  discovers cache alias bug in vgsplit test,
fix it by using better filter line.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c   |   12 ++----------
 test/t-vgsplit-stacked.sh |    2 +-
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f1b90a7..f079554 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1294,17 +1294,9 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 
 	/* Is there an md superblock here? */
 	if (!dev && md_filtering()) {
-		unlock_vg(cmd, VG_ORPHANS);
-
-		persistent_filter_wipe(cmd->filter);
-		lvmcache_destroy(cmd, 1);
-
+		refresh_filters(cmd);
 		init_md_filtering(0);
-		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-			log_error("Can't get lock for orphan PVs");
-			init_md_filtering(1);
-			return 0;
-		}
+		lvmcache_label_scan(cmd, 0);
 		dev = dev_cache_get(name, cmd->filter);
 		init_md_filtering(1);
 	}
diff --git a/test/t-vgsplit-stacked.sh b/test/t-vgsplit-stacked.sh
index 46cb105..fb4e659 100644
--- a/test/t-vgsplit-stacked.sh
+++ b/test/t-vgsplit-stacked.sh
@@ -1,6 +1,6 @@
 . ./test-utils.sh
 
-prepare_lvmconf '[ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "r/.*/" ]'
+prepare_lvmconf '[ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
 aux prepare_devs 3
 
 pvcreate $devs
-- 
1.7.0


