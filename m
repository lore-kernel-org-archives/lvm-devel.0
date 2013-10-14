From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 14 Oct 2013 15:50:39 +0000 (UTC)
Subject: master - RAID: Report RAID images split with tracking as out-of-sync ("I").
Message-ID: <20131014155039.A64FF60D8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f58b26b6338b2939e6a88174ac2dc185b345118b
Commit:        f58b26b6338b2939e6a88174ac2dc185b345118b
Parent:        0f55d7ccccb2c274f31760d1c97286ee03e24e4c
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Oct 14 10:48:44 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Oct 14 10:48:44 2013 -0500

RAID: Report RAID images split with tracking as out-of-sync ("I").

Split image should have an out-of-sync attr ('I') - always.  Even if
the RAID LV has not been written to since the LV was split off, it is
still not part of the group that makes up the RAID and is therefore
"out-of-sync".
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    8 +++++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 887a256..04be5f1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Report RAID images split with tracking as out-of-sync ("I").
   Improve parsing of snapshot lv segment.
   Add workaround for deactivation problem of opened virtual snapshot.
   Disable unsupported merge for virtual snapshot.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e3fda18..e59bd8e 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -565,7 +565,13 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	else if (lv->status & MIRROR_IMAGE)
 		repstr[0] = (_lv_mimage_in_sync(lv)) ? 'i' : 'I';
 	else if (lv->status & RAID_IMAGE)
-		repstr[0] = (_lv_raid_image_in_sync(lv)) ? 'i' : 'I';
+		/*
+		 * Visible RAID_IMAGES are sub-LVs that have been exposed for
+		 * top-level use by being split from the RAID array with
+		 * '--splitmirrors 1 --trackchanges'.  They always report 'I'.
+		 */
+		repstr[0] = (!lv_is_visible(lv) && _lv_raid_image_in_sync(lv)) ?
+			'i' : 'I';
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
 	else if (lv_is_cow(lv))


