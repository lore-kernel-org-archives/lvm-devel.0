From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:53:40 +0000 (UTC)
Subject: master - thin: lvconvert warn before conversion
Message-ID: <20140520195340.A7E6E60190@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bbf4b2c1c9da174c607daee9f920f32517d48e6a
Commit:        bbf4b2c1c9da174c607daee9f920f32517d48e6a
Parent:        83f468be4e8ff6189523eae7de8a087ab42021be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 16:21:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:48:47 2014 +0200

thin: lvconvert warn before conversion

Warn user before converting volume to different type.

  WARNING: Converting vg/lvol0 logical volume to pool's meta/data volume.
  THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)

Since the content of volume is lost we have to query user to confirm
such operation.  If user is 100% sure, he may use '--yes' to avoid prompts.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   22 ++++++++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 51249ed..5e13c04 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Prompt before converting volumes to thin pool and thin pool metadata.
   Add dumpconfig --type profilable-{metadata,command} to select profile type.
   Exit immediately with error if command profile is found invalid.
   Separate --profile cmd line arg into --commandprofile and --metadataprofile.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 94d870a..79a78a4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2718,6 +2718,17 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	log_warn("WARNING: Converting \"%s/%s\" logical volume to pool's data volume.",
+		 pool_lv->vg->name, pool_lv->name);
+	log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+
+	if (!lp->yes &&
+	    yes_no_prompt("Do you really want to convert \"%s/%s\"? [y|n]: ",
+			  pool_lv->vg->name, pool_lv->name) == 'n') {
+		log_error("Conversion aborted.");
+		return 0;
+	}
+
 	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s%s",
 			 pool_lv->name,
 			 (segtype_is_cache_pool(lp->segtype)) ?
@@ -2825,6 +2836,17 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			return 0;
 		}
 
+		log_warn("WARNING: Converting \"%s/%s\" logical volume to pool's metadata volume.",
+			 metadata_lv->vg->name, metadata_lv->name);
+		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+
+		if (!lp->yes &&
+		    yes_no_prompt("Do you really want to convert \"%s/%s\"? [y|n]: ",
+				  metadata_lv->vg->name, metadata_lv->name) == 'n') {
+			log_error("Conversion aborted.");
+			return 0;
+		}
+
 		lp->poolmetadata_size = metadata_lv->size;
 		max_metadata_size = (segtype_is_cache_pool(lp->segtype)) ?
 			DEFAULT_CACHE_POOL_MAX_METADATA_SIZE * 2 :


