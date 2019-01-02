From: David Teigland <teigland@sourceware.org>
Date: Wed, 2 Jan 2019 12:57:18 -0500
Subject: master - writecache: prompt before using an LV to hold cache
Message-ID: <201901021757.x02HvI0l007832@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=938b6b8253c7aadb8947c574cc5f480ed2c1b696
Commit:        938b6b8253c7aadb8947c574cc5f480ed2c1b696
Parent:        89c61f2018c843a7dabc617ba152b99656ee9849
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 2 11:44:03 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 2 11:44:03 2019 -0600

writecache: prompt before using an LV to hold cache

---
 test/shell/writecache.sh |    4 ++--
 tools/lvconvert.c        |    6 ++++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index ce77cfe..42c864a 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -48,7 +48,7 @@ cp pattern1 $mount_dir/pattern1
 umount $mount_dir
 lvchange -an $vg/$lv1
 
-lvconvert --type writecache --cachepool $lv2 $vg/$lv1
+lvconvert --yes --type writecache --cachepool $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype writecache
 
@@ -90,7 +90,7 @@ lvchange -an $vg/$lv2
 
 # test2: create fs on LV after writecache is attached
 
-lvconvert --type writecache --cachepool $lv2 $vg/$lv1
+lvconvert --yes --type writecache --cachepool $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype writecache
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3ba7f5b..2c6384e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5498,6 +5498,12 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!arg_is_set(cmd, yes_ARG) &&
+	    yes_no_prompt("Erase all existing data on %s? [y/n]: ", display_lvname(lv_fast)) == 'n') {
+		log_error("Conversion aborted.");
+		return 0;
+	}
+
 	/* Ensure the two LVs are not active elsewhere. */
 	if (!lockd_lv(cmd, lv, "ex", 0))
 		goto_bad;


