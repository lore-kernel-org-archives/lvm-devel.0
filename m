From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:29 +0000 (UTC)
Subject: master - cleanup: condition reodering
Message-ID: <20140211180129.D369460FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f86e18bfeb8f047ac3fdc2b7a95e2f80a0bcdbfb
Commit:        f86e18bfeb8f047ac3fdc2b7a95e2f80a0bcdbfb
Parent:        bcd6b643be0aaef1df06a4df482a8e528d3cd36a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 11 13:42:32 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 19:00:06 2014 +0100

cleanup: condition reodering

Check SEG_CANNOT_BE_ZEROED before even calling arg_str_value which
is not needed in this case.

Set it to 1 or 0 and not just result of strcmp call.
---
 tools/lvcreate.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 638a868..bf719fe 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1003,13 +1003,13 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	/*
 	 * Should we zero/wipe signatures on the lv.
 	 */
-	lp->zero = strcmp(arg_str_value(cmd, zero_ARG,
-		(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? "n" : "y"), "n");
+	lp->zero = (!(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) &&
+		    (strcmp(arg_str_value(cmd, zero_ARG, "y"), "y") == 0)) ? 1 : 0;
 
 	if (arg_count(cmd, wipesignatures_ARG)) {
 		/* If -W/--wipesignatures is given on command line directly, respect it. */
-		lp->wipe_signatures = strcmp(arg_str_value(cmd, wipesignatures_ARG,
-			(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? "n" : "y"), "n");
+		lp->wipe_signatures =(!(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) &&
+				      (strcmp(arg_str_value(cmd, wipesignatures_ARG, "y"), "y") == 0)) ? 1 : 0;
 	} else {
 		/*
 		 * If -W/--wipesignatures is not given on command line,


