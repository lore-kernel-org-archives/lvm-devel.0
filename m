From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 24 Jul 2009 20:08:15 -0400
Subject: [PATCH 06/11] Move pvs and pv_count fields from lvcreate_params to lvcreate_cmdline_params.
In-Reply-To: <1248480500-472-6-git-send-email-dwysocha@redhat.com>
References: <1248480500-472-1-git-send-email-dwysocha@redhat.com>
	<1248480500-472-2-git-send-email-dwysocha@redhat.com>
	<1248480500-472-3-git-send-email-dwysocha@redhat.com>
	<1248480500-472-4-git-send-email-dwysocha@redhat.com>
	<1248480500-472-5-git-send-email-dwysocha@redhat.com>
	<1248480500-472-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1248480500-472-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

No functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvcreate.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index b6558f8..aadf519 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -21,6 +21,8 @@
 struct lvcreate_cmdline_params {
 	percent_t percent;
 	uint64_t size;
+	char **pvs;
+	int pv_count;
 };
 
 /* FIXME: refactor and reduce the size of this struct! */
@@ -56,8 +58,6 @@ struct lvcreate_params {
 	uint32_t read_ahead; /* all */
 	alloc_policy_t alloc; /* all */
 
-	int pv_count; /* all; redundant? */
-	char **pvs; /* all; redundant? */
 	const char *tag; /* all */
 };
 
@@ -185,9 +185,9 @@ static int _update_extents_params(struct volume_group *vg,
 	 * Create the pv list before we parse lcp->percent - might be
 	 * PERCENT_PVSs
 	 */
-	if (lp->pv_count) {
+	if (lcp->pv_count) {
 		if (!(lp->pvh = create_pv_list(vg->cmd->mem, vg,
-					   lp->pv_count, lp->pvs, 1)))
+					   lcp->pv_count, lcp->pvs, 1)))
 			return_0;
 	} else
 		lp->pvh = &vg->pvs;
@@ -200,7 +200,7 @@ static int _update_extents_params(struct volume_group *vg,
 			lp->extents = lp->extents * vg->free_count / 100;
 			break;
 		case PERCENT_PVS:
-			if (!lp->pv_count) {
+			if (!lcp->pv_count) {
 				log_error("Please specify physical volume(s) "
 					  "with %%PVS");
 				return 0;
@@ -603,8 +603,8 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-	lp->pv_count = argc;
-	lp->pvs = argv;
+	lcp->pv_count = argc;
+	lcp->pvs = argv;
 
 	return 1;
 }
-- 
1.6.0.6


