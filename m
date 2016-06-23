From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 23:03:20 +0000 (UTC)
Subject: master - lvresize: fixes for recent commit
Message-ID: <20160623230320.71D8960CAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1bb7a155d169c3fc115533658206c242f43bdd0c
Commit:        1bb7a155d169c3fc115533658206c242f43bdd0c
Parent:        e99a31c9502a2081c6608a831b601081008cc3b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 24 00:24:26 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 24 00:39:14 2016 +0200

lvresize: fixes for recent commit

Merging process and patch rework missed some bits - fix them.
---
 lib/metadata/lv_manip.c |    7 +++++--
 tools/lvresize.c        |    6 +-----
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8f07267..40c1c1a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4452,7 +4452,7 @@ static uint32_t _adjust_amount(dm_percent_t percent, int policy_threshold, int p
 	percent = (percent / policy_threshold + (DM_PERCENT_1 - 1) / 100) / (DM_PERCENT_1 / 100) - 100;
 
 	/* Use it if current policy amount is smaller */
-	return (policy_amount < percent) ? (uint32_t) policy_amount : (uint32_t) percent;
+	return (policy_amount < percent) ? (uint32_t) percent : (uint32_t) policy_amount;
 }
 
 static int _lvresize_adjust_policy(const struct logical_volume *lv,
@@ -5241,7 +5241,10 @@ int lv_resize(struct logical_volume *lv,
 		return_0;
 
 	if (lp->use_policies) {
-		lp->percent = SIGN_PLUS;
+		lp->extents = 0;
+		lp->sign = SIGN_PLUS;
+		lp->percent = PERCENT_LV;
+
 		aux_lp = *lp;
 		if (!_lvresize_adjust_policy(lv, &lp->extents, &aux_lp.extents))
 			return_0;
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 45d3558..35b7044 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -34,11 +34,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->sign = lp->poolmetadata_sign = SIGN_NONE;
 
 	if ((lp->use_policies = arg_is_set(cmd, usepolicies_ARG))) {
-		/* do nothing; _lvresize will handle --use-policies itself */
-		lp->extents = 0;
-		lp->sign = SIGN_PLUS;
-		lp->percent = PERCENT_LV;
-
+		/* do nothing; lv_resize will handle --use-policies itself */
 		if (arg_from_list_is_set(cmd, NULL,
 					 chunksize_ARG, extents_ARG,
 					 poolmetadatasize_ARG,


