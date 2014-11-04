From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Nov 2014 14:32:57 +0000 (UTC)
Subject: master - lvconvert: convert missing sizes to extents
Message-ID: <20141104143257.87AD06101B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7092b47ec90571668c30ef38a9ec251adcff2c82
Commit:        7092b47ec90571668c30ef38a9ec251adcff2c82
Parent:        847b2aa5b418c80d4fe2fb68dec32e7992416ba0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 14:14:52 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 4 15:25:47 2014 +0100

lvconvert: convert missing sizes to extents

After initial 'size' usage converted to extents, continue to use
only extents.

(in-release fix).
---
 tools/lvconvert.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 22058ea..fcec8e1 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2842,7 +2842,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			log_error("Unknown pool metadata LV %s.", lp->pool_metadata_name);
 			return 0;
 		}
-		lp->pool_metadata_size = lp->pool_metadata_lv->size;
+		lp->pool_metadata_extents = lp->pool_metadata_lv->le_count;
 		metadata_lv = lp->pool_metadata_lv;
 
 		if (metadata_lv == pool_lv) {
@@ -2885,7 +2885,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			if (!_lvconvert_update_pool_params(pool_lv, lp))
 				return_0;
 
-			if (lp->pool_metadata_size > metadata_lv->size) {
+			if (lp->pool_metadata_extents > metadata_lv->le_count) {
 				log_error("Logical volume %s is too small for metadata.",
 					  display_lvname(metadata_lv));
 				return 0;
@@ -2953,7 +2953,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		if (!_lvconvert_update_pool_params(pool_lv, lp))
 			return_0;
 
-		if (metadata_lv->size < lp->pool_metadata_size)
+		if (metadata_lv->le_count < lp->pool_metadata_extents)
 			log_print_unless_silent("Continuing with swap...");
 
 		if (!arg_count(cmd, discards_ARG))


