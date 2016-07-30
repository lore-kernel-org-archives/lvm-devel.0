From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 30 Jul 2016 01:53:54 +0000 (UTC)
Subject: master - lvconvert: Move stripe validation code later.
Message-ID: <20160730015355.0340060F8E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3fbcd1ff7cae307b2796fe0df9ef32655f6f87a
Commit:        b3fbcd1ff7cae307b2796fe0df9ef32655f6f87a
Parent:        4ffe15bf6aec1ef8a14d3c070fc6b9bbb40cd4b0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 30 02:52:06 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 30 02:52:06 2016 +0100

lvconvert: Move stripe validation code later.

Simpler to delay it all until the actual LV being changed is available,
rather than having it split in two parts.
---
 tools/lvconvert.c |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 33c7ffb..b9aef53 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -808,23 +808,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		return 0;
 	}
 
-	/* Process striping parameters */
-	/* FIXME This is incomplete */
-	if (_mirror_or_raid_type_requested(cmd, lp->type_str) || _raid0_type_requested(lp->type_str) ||
-	    _striped_type_requested(lp->type_str) || lp->repair || lp->mirrorlog || lp->corelog) {
-		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size))
-			return_0;
-
-		if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str))
-			/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */
-			/* The default keeps existing number of stripes, handled inside the library code */
-			if (!arg_is_set(cmd, stripes_long_ARG) && !_linear_type_requested(lp->type_str))
-				lp->stripes = 0;
-	}
-
-	if (lp->snapshot)
-		lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? 0 : arg_int_value(cmd, zero_ARG, 1);
-
 	return 1;
 }
 
@@ -4393,6 +4376,23 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!lp->segtype)
 		lp->segtype = seg->segtype;
 
+	/* Process striping parameters */
+	/* FIXME This is incomplete */
+	if (_mirror_or_raid_type_requested(cmd, lp->type_str) || _raid0_type_requested(lp->type_str) ||
+	    _striped_type_requested(lp->type_str) || lp->repair || lp->mirrorlog || lp->corelog) {
+		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size))
+			return_0;
+
+		if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str))
+			/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */
+			/* The default keeps existing number of stripes, handled inside the library code */
+			if (!arg_is_set(cmd, stripes_long_ARG) && !_linear_type_requested(lp->type_str))
+				lp->stripes = 0;
+	}
+
+	if (lp->snapshot)
+		lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? 0 : arg_int_value(cmd, zero_ARG, 1);
+
 	/*
 	 * Each LV type that can be converted.
 	 * (The existing type of the LV, not a requested type.)


