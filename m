From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Aug 2013 12:55:40 +0000 (UTC)
Subject: master - thin: support lvchange for data and metadata
Message-ID: <20130826125540.7533060E7A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b416f837f4ee71ca5705cb40fad22b26b0c664a
Commit:        6b416f837f4ee71ca5705cb40fad22b26b0c664a
Parent:        7d6a125e97085ea140c582a0b6c1ef2ca4cb0f93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 10 01:13:27 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 26 14:55:22 2013 +0200

thin: support lvchange for data and metadata

Support lvchange operation on stacked thin pool data and metadata
volumes.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    8 +++++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3ea8786..bf13023 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Support most of lvchange operations on stacked thin pool meta/data LVs.
   Add ability to pvmove RAID, mirror, and thin volumes.
   Make lvm2-activation-generator silent unless it's in error state.
   Remove "mpath major is not dm major" msg for mpath component scan (2.02.94).
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 525022f..34e230c 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -982,7 +982,13 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    lv_is_virtual_origin(origin = origin_from_cow(lv)))
 		lv = origin;
 
-	if (!(lv_is_visible(lv)) && !lv_is_virtual_origin(lv)) {
+	if ((lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv)) &&
+	    !arg_count(cmd, activate_ARG) &&
+	    !arg_count(cmd, permission_ARG) &&
+	    !arg_count(cmd, setactivationskip_ARG))
+	    /* Rest can be changed for stacked thin pool meta/data volumes */
+	    ;
+	else if (!(lv_is_visible(lv)) && !lv_is_virtual_origin(lv)) {
 		log_error("Unable to change internal LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;


