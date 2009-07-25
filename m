From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 24 Jul 2009 20:08:13 -0400
Subject: [PATCH 04/11] Move 'size' from lvcreate_params into lvcreate_cmdline_params.
In-Reply-To: <1248480500-472-4-git-send-email-dwysocha@redhat.com>
References: <1248480500-472-1-git-send-email-dwysocha@redhat.com>
	<1248480500-472-2-git-send-email-dwysocha@redhat.com>
	<1248480500-472-3-git-send-email-dwysocha@redhat.com>
	<1248480500-472-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1248480500-472-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The main _lvcreate function should deal with extents - the 'size' parameter
is just an intermediate step.
Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvcreate.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index f921d40..cca8fc8 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -20,6 +20,7 @@
 
 struct lvcreate_cmdline_params {
 	percent_t percent;
+	uint64_t size;
 };
 
 /* FIXME: refactor and reduce the size of this struct! */
@@ -47,7 +48,6 @@ struct lvcreate_params {
 
 	/* size */
 	uint32_t extents;
-	uint64_t size;
 	uint32_t voriginextents;
 	uint64_t voriginsize;
 	struct dm_list *pvh;
@@ -171,8 +171,8 @@ static int _update_extents_params(struct volume_group *vg,
 {
 	uint32_t pv_extent_count;
 
-	if (lp->size &&
-	    !(lp->extents = _extents_from_size(vg->cmd, lp->size,
+	if (lcp->size &&
+	    !(lp->extents = _extents_from_size(vg->cmd, lcp->size,
 					       vg->extent_size)))
 		return_0;
 
@@ -242,7 +242,7 @@ static int _read_size_params(struct lvcreate_params *lp,
 			log_error("Negative size is invalid");
 			return 0;
 		}
-		lp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
+		lcp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
 		lcp->percent = PERCENT_NONE;
 	}
 
-- 
1.6.0.6


