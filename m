From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Nov 2012 13:48:50 +0000 (UTC)
Subject: master - cleanup: move setting of parameter zero
Message-ID: <20121119134850.C9E4C1698@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c3bbf0a6cf33de8f1b2a08fcb79da3f881d3472
Commit:        2c3bbf0a6cf33de8f1b2a08fcb79da3f881d3472
Parent:        54c73b7723713f43413584d59ca0bdd42c1d8241
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 15 14:47:37 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 14:15:43 2012 +0100

cleanup: move setting of parameter zero

Since we may need to use different default value,
move read of zero_ARG prior processing of parameters.
---
 tools/lvcreate.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 3ea8f46..5d687ac 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -812,6 +812,12 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
+	/*
+	 * Should we zero the lv.
+	 */
+	lp->zero = strcmp(arg_str_value(cmd, zero_ARG,
+		(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? "n" : "y"), "n");
+
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
@@ -877,12 +883,6 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-	/*
-	 * Should we zero the lv.
-	 */
-	lp->zero = strcmp(arg_str_value(cmd, zero_ARG,
-		(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? "n" : "y"), "n");
-
 	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
 		log_error("Only up to %d images in mirror supported currently.",
 			  DEFAULT_MIRROR_MAX_IMAGES);


