From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 24 Jul 2009 20:08:17 -0400
Subject: [PATCH 08/11] Move extents_from_size from lvcreate into internal library so we can reuse.
In-Reply-To: <1248480500-472-8-git-send-email-dwysocha@redhat.com>
References: <1248480500-472-1-git-send-email-dwysocha@redhat.com>
	<1248480500-472-2-git-send-email-dwysocha@redhat.com>
	<1248480500-472-3-git-send-email-dwysocha@redhat.com>
	<1248480500-472-4-git-send-email-dwysocha@redhat.com>
	<1248480500-472-5-git-send-email-dwysocha@redhat.com>
	<1248480500-472-6-git-send-email-dwysocha@redhat.com>
	<1248480500-472-7-git-send-email-dwysocha@redhat.com>
	<1248480500-472-8-git-send-email-dwysocha@redhat.com>
Message-ID: <1248480500-472-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    3 +++
 lib/metadata/metadata.c          |   22 ++++++++++++++++++++++
 tools/lvcreate.c                 |   29 ++---------------------------
 3 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 345992f..370be25 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -475,6 +475,9 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	      const char *new_name);
 
+uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
+			   uint32_t extent_size);
+
 /* FIXME: refactor and reduce the size of this struct! */
 struct lvcreate_params {
 	/* flags */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3a59cf2..2871a93 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -686,6 +686,28 @@ bad:
 	return NULL;
 }
 
+uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
+			   uint32_t extent_size)
+{
+	if (size % extent_size) {
+		size += extent_size - size % extent_size;
+		log_print("Rounding up size to full physical extent %s",
+			  display_size(cmd, size));
+	}
+
+	if (size > (uint64_t) UINT32_MAX * extent_size) {
+		log_error("Volume too large (%s) for extent size %s. "
+			  "Upper limit is %s.",
+			  display_size(cmd, size),
+			  display_size(cmd, (uint64_t) extent_size),
+			  display_size(cmd, (uint64_t) UINT32_MAX *
+				       extent_size));
+		return 0;
+	}
+
+	return (uint64_t) size / extent_size;
+}
+
 static int _recalc_extents(uint32_t *extents, const char *desc1,
 			   const char *desc2, uint32_t old_size,
 			   uint32_t new_size)
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8c13954..53943d7 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -25,9 +25,6 @@ struct lvcreate_cmdline_params {
 	int pv_count;
 };
 
-static uint64_t _extents_from_size(struct cmd_context *cmd, uint64_t size,
-				   uint32_t extent_size);
-
 static int _lvcreate_name_params(struct lvcreate_params *lp,
 				 struct cmd_context *cmd,
 				 int *pargc, char ***pargv)
@@ -136,12 +133,12 @@ static int _update_extents_params(struct volume_group *vg,
 	uint32_t pv_extent_count;
 
 	if (lcp->size &&
-	    !(lp->extents = _extents_from_size(vg->cmd, lcp->size,
+	    !(lp->extents = extents_from_size(vg->cmd, lcp->size,
 					       vg->extent_size)))
 		return_0;
 
 	if (lp->voriginsize &&
-	    !(lp->voriginextents = _extents_from_size(vg->cmd, lp->voriginsize,
+	    !(lp->voriginextents = extents_from_size(vg->cmd, lp->voriginsize,
 						      vg->extent_size)))
 		return_0;
 
@@ -573,28 +570,6 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	return 1;
 }
 
-static uint64_t _extents_from_size(struct cmd_context *cmd, uint64_t size,
-				   uint32_t extent_size)
-{
-	if (size % extent_size) {
-		size += extent_size - size % extent_size;
-		log_print("Rounding up size to full physical extent %s",
-			  display_size(cmd, size));
-	}
-
-	if (size > (uint64_t) UINT32_MAX * extent_size) {
-		log_error("Volume too large (%s) for extent size %s. "
-			  "Upper limit is %s.",
-			  display_size(cmd, size),
-			  display_size(cmd, (uint64_t) extent_size),
-			  display_size(cmd, (uint64_t) UINT32_MAX *
-				       extent_size));
-		return 0;
-	}
-
-	return (uint64_t) size / extent_size;
-}
-
 int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int r = ECMD_PROCESSED;
-- 
1.6.0.6


