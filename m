From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:17 -0400
Subject: master - cachevol: wipe 'normal' device
Message-ID: <201910141322.x9EDMHaV018774@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f6d171ffe33455ab48e142820aa74be901e8aee9
Commit:        f6d171ffe33455ab48e142820aa74be901e8aee9
Parent:        615e18f5b2356bd1fd134bc24ea790fa6ec0653f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 11 15:27:41 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:14:46 2019 +0200

cachevol: wipe 'normal' device

For wiping we activate and clear 'regular' devices,
since in case of whole process interuption (i.e. kill -9)
we leave metadata & DM table and workable state all the time.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    8 +++-----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bb806ac..6405686 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Use normal LVs for wiping of cachevols.
   Reload cleanered cache DM only with cleaner policy.
   Fix cmd return when zering of cachevol fails.
   Extend lvs to show all VDO properties.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8ecbf34..885380c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4224,8 +4224,6 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 	if (!lockd_lv(cmd, cachevol_lv, "ex", LDLV_PERSISTENT))
 		goto_out;
 
-	cachevol_lv->status |= LV_CACHE_VOL;
-
 	if (!wipe_cache_pool(cachevol_lv))
 		goto_out;
 
@@ -4240,7 +4238,7 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 		goto_out;
 
 	/* Attach the cache to the main LV. */
-
+	cachevol_lv->status |= LV_CACHE_VOL;
 	if (!_cache_vol_attach(cmd, lv, cachevol_lv))
 		goto_out;
 
@@ -5551,8 +5549,6 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	if (!archive(vg))
 		goto_bad;
 
-	lv_fast->status |= LV_CACHE_VOL;
-
 	/*
 	 * TODO: use libblkid to get the sector size of lv.  If it doesn't
 	 * match the block_size we are using for the writecache, then warn that
@@ -5567,6 +5563,8 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		return ECMD_FAILED;
 	}
 
+	lv_fast->status |= LV_CACHE_VOL;
+
 	/*
 	 * Changes the vg struct to match the desired state.
 	 *


