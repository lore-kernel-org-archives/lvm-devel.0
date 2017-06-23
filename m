From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 17:33:35 -0400
Subject: master - raid: recognize transient failed raid leg
Message-ID: <201706232133.v5NLXZwW022533@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b18be87aa7cc1439e8b138690f79dd4eed73afc
Commit:        2b18be87aa7cc1439e8b138690f79dd4eed73afc
Parent:        535f7209d2c0fa996928f82b3668560ad489e742
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 22:50:19 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 23:27:07 2017 +0200

raid: recognize transient failed raid leg

When raid leg rimage device is marked as 'D'ead by mdcore,
lvm2 was not able to replace such device with allocate policy,
as device has not appared as missing.

Add detection of transiently failing devices.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |    2 ++
 tools/lvconvert.c         |    2 ++
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 19f7a31..fa51f67 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Lvconvert --repair handles failing raid legs (present but marked 'D'ead).
   Do not lvdisplay --maps unset settings of cache pool.
   Fix lvdisplay --maps for cache pool without policy settings.
   Support aborting of flushing cache LV.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c943976..2a427ab 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6653,6 +6653,8 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 
 		if (lv_is_virtual(seg_lv(raid_seg, s)) ||
 		    lv_is_virtual(seg_metalv(raid_seg, s)) ||
+		    lv_is_partial(seg_lv(raid_seg, s)) ||
+		    lv_is_partial(seg_metalv(raid_seg, s)) ||
 		    lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
 		    lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs)) {
 			match_count++;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 821146f..5e255d3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3319,6 +3319,8 @@ static int _lvconvert_repair_pvs_raid(struct cmd_context *cmd, struct logical_vo
 		return 0;
 	}
 
+	lv_check_transient(lv); /* TODO check this in lib for all commands? */
+
 	_lvconvert_repair_pvs_raid_ask(cmd, &do_it);
 
 	if (do_it) {


