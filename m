From: David Teigland <teigland@sourceware.org>
Date: Fri, 22 May 2020 19:12:58 +0000 (GMT)
Subject: master - lvconvert: error when using existing cachevol
Message-ID: <20200522191258.6DB6C386F83C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74a211cfd30e93d9388de5ac1ee22e630c840e94
Commit:        74a211cfd30e93d9388de5ac1ee22e630c840e94
Parent:        bb41ca86fa962dd5d90c2b5498e93bb8a3aa2f91
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 22 13:44:33 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 22 14:12:34 2020 -0500

lvconvert: error when using existing cachevol

Check if LV is an existing cachevol before attempting
to use it again as a cachevol or cachepool.
---
 test/shell/cache-single-usage.sh | 13 +++++++++++++
 tools/lvconvert.c                | 15 +++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/test/shell/cache-single-usage.sh b/test/shell/cache-single-usage.sh
index a885bf793..8936aa3f1 100644
--- a/test/shell/cache-single-usage.sh
+++ b/test/shell/cache-single-usage.sh
@@ -127,4 +127,17 @@ umount "$mount_dir"
 lvchange -an $vg/$lv1
 lvchange -an $vg/$lv2
 
+# misc tests
+
+lvremove $vg
+
+lvcreate -n $lv1 -l 2 -an $vg "$dev1"
+lvcreate -n $lv2 -l 2 -an $vg "$dev1"
+lvcreate -n $lv3 -l 2 -an $vg "$dev2"
+
+lvconvert -y --type writecache --cachevol $lv3 $vg/$lv1
+not lvconvert -y --type writecache --cachevol ${lv3}_cvol $vg/$lv2
+not lvconvert -y --type cache --cachevol ${lv3}_cvol $vg/$lv2
+not lvconvert -y --type cache --cachepool ${lv3}_cvol $vg/$lv2
+
 vgremove -ff $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index cf935385f..8652252d3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4264,6 +4264,11 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 		goto out;
 	}
 
+	if (lv_is_cache_vol(cachevol_lv)) {
+		log_error("LV %s is already used as a cachevol.", display_lvname(cachevol_lv));
+		goto out;
+	}
+
 	/* Ensure the LV is not active elsewhere. */
 	if (!lockd_lv(cmd, lv, "ex", 0))
 		goto_out;
@@ -4347,6 +4352,11 @@ static int _lvconvert_cachepool_attach_single(struct cmd_context *cmd,
 			goto out;
 		}
 
+		if (lv_is_cache_vol(cachepool_lv)) {
+			log_error("LV %s is already used as a cachevol.", display_lvname(cachepool_lv));
+			goto out;
+		}
+
 		if (cachepool_lv == lv) {
 			log_error("Use a different LV for cache pool LV and cache LV %s.",
 				  display_lvname(cachepool_lv));
@@ -5629,6 +5639,11 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		goto bad;
 	}
 
+	if (lv_is_cache_vol(lv_fast)) {
+		log_error("LV %s is already used as a cachevol.", display_lvname(lv_fast));
+		goto bad;
+	}
+
 	/*
 	 * To permit this we need to check the block size of the fs using lv
 	 * (recently in libblkid) so that we can use a matching writecache


