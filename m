From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Nov 2014 23:50:47 +0000 (UTC)
Subject: master - pool: prevent pool conversion with same name
Message-ID: <20141122235047.7D52460E99@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8eb111dfb81c4615826747653d88259e311b2982
Commit:        8eb111dfb81c4615826747653d88259e311b2982
Parent:        078230971358c38b124fabb59b0dd3d92521b6f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 22 23:37:31 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Nov 23 00:49:04 2014 +0100

pool: prevent pool conversion with same name

When same name is given for converted volume and pool volume,
stop further command processing.
---
 WHATS_NEW                    |    1 +
 test/shell/lvconvert-thin.sh |    3 +++
 tools/lvconvert.c            |   15 +++++++++++----
 3 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3b3e414..19f1d2a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.113 - 
 =====================================
+  Validate converted volume and specified pool volume differ.
   Fix regression in vgscan --mknodes usage (2.02.112).
   Respect --prefix when setting CLMVD_PATH configure (2.02.89).
   Default to configure --enable-udev-systemd-background-jobs for systemd>=205.
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index e61e470..74484b1 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -103,6 +103,9 @@ invalid lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # non multiple of 64KiB fails
 invalid lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
+# cannot use same LV for pool and convertion
+fail lvconvert --yes --thinpool $vg/$lv3 -T $vg/$lv3
+
 # Warning about smaller then suggested
 lvconvert --yes -c 256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
 grep "WARNING: Chunk size is smaller" err
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d4f3db1..8436c24 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2784,10 +2784,17 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 	char metadata_name[NAME_LEN], data_name[NAME_LEN];
 	int activate_pool;
 
-	if (lp->pool_data_name &&
-	    !(pool_lv = find_lv(vg, lp->pool_data_name))) {
-		log_error("Unknown pool data LV %s.", lp->pool_data_name);
-		return 0;
+	if (lp->pool_data_name) {
+		if ((lp->thin || lp->cache) &&
+		    !strcmp(lp->pool_data_name, pool_lv->name)) {
+			log_error("Converted volume %s and pool volume must differ.",
+				  display_lvname(pool_lv));
+			return 0;
+		}
+		if (!(pool_lv = find_lv(vg, lp->pool_data_name))) {
+			log_error("Unknown pool data LV %s.", lp->pool_data_name);
+			return 0;
+		}
 	}
 
 	if (!lv_is_visible(pool_lv)) {


