From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Aug 2014 12:17:28 +0000 (UTC)
Subject: master - thin: more forced ignoring of pool failure
Message-ID: <20140826121728.5917761018@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ee5e18a7b446bc08d99a5638fc4463e459b34d3
Commit:        1ee5e18a7b446bc08d99a5638fc4463e459b34d3
Parent:        f4e56b28299680783b8375235bdd2bd48a9934e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 26 11:53:56 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 26 14:09:04 2014 +0200

thin: more forced ignoring of pool failure

Support also 'vgremove -ff' to properly remove even inactive/broken thin pools.
Update messages to use 'print_unless_silent' for the forced case.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   14 +++++++++-----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c42d1d5..13e6129 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  Support lv/vgremove -ff to remove thin vols from broken/inactive thin pools.
   Fix typo breaking configure --with-lvm1=shared.
   Modify lvresize code to handle raid/mirrors and physical extents.
   Allow conversion of raid1 LV into a snapshot LV or snapshot origin LV.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fa91c4e..5cc0079 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5522,11 +5522,11 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (pool_lv && !pool_has_message(first_seg(pool_lv), lv, 0) &&
 	    !update_pool_lv(pool_lv, 1)) {
 		if (force < DONT_PROMPT_OVERRIDE) {
-			log_error("Failed to update thin pool %s.", pool_lv->name);
+			log_error("Failed to update pool %s.", display_lvname(pool_lv));
 			return 0;
 		}
-		log_warn("WARNING: Forced to ignoring failure of pool metadata update %s.",
-			 pool_lv->name);
+		log_print_unless_silent("Ignoring update failure of pool %s.",
+					display_lvname(pool_lv));
 		pool_lv = NULL; /* Do not retry */
 	}
 
@@ -5565,8 +5565,12 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* Release unneeded blocks in thin pool */
 	/* TODO: defer when multiple LVs relased at once */
 	if (pool_lv && !update_pool_lv(pool_lv, 1)) {
-		log_error("Failed to update thin pool %s.", pool_lv->name);
-		return 0;
+		if (force < DONT_PROMPT_OVERRIDE) {
+			log_error("Failed to update pool %s.", display_lvname(pool_lv));
+			return 0;
+		}
+		log_print_unless_silent("Ignoring update failure of pool %s.",
+					display_lvname(pool_lv));
 	}
 
 	backup(vg);


