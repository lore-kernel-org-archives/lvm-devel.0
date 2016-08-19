From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 19 Aug 2016 13:22:17 +0000 (UTC)
Subject: master - lvcreate: No longer adjust --stripes for raid types.
Message-ID: <20160819132217.7F66660E91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea0f604e704dc8418d962e20529fd1bcddf06bb7
Commit:        ea0f604e704dc8418d962e20529fd1bcddf06bb7
Parent:        c1a0a2c7121af78d469f3908d6a7763b51f377a5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 19 14:19:51 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 19 14:19:51 2016 +0100

lvcreate: No longer adjust --stripes for raid types.

If the number of stripes requested is incompatible with the requested
type of raid, give an error instead of adjusting it.

If no stripes argument is supplied, continue to use an appropriate
default.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |   28 ++++++++++++++++++++++++----
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e2a9622..764cc73 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  No longer adjust incorrect number of raid stripes supplied to lvcreate.
   Move lcm and gcd to lib/misc.
   Suppress some unnecessary --stripesize parameter warnings.
   Fix 'pvmove -n name ...' to prohibit collocation of RAID SubLVs
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 6fd0fb9..d3a64af 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -464,6 +464,12 @@ static int _read_raid_params(struct cmd_context *cmd,
 				/*
 				 * RAID10 needs at least 4 stripes
 				 */
+				if (lp->stripes_supplied) {
+					log_error("Minimum of 2 stripes required for %s.",
+						  lp->segtype->name);
+					return 0;
+				}
+
 				log_warn("Adjusting stripes to the minimum of 2 for %s.",
 					 lp->segtype->name);
 				lp->stripes = 2;
@@ -480,14 +486,28 @@ static int _read_raid_params(struct cmd_context *cmd,
 			/*
 			 * RAID1 does not take a stripe arg
 			 */
-			log_error("Stripe argument cannot be used with segment type, %s",
+			log_error("Stripes argument cannot be used with segment type, %s",
 				  lp->segtype->name);
 			return 0;
 		}
 
-	} else if (lp->stripes < 2)
-		/* No stripes argument was given */
-		lp->stripes = seg_is_any_raid6(lp) ? 3 : 2;
+	} else if (seg_is_any_raid6(lp) && lp->stripes < 3) {
+		if (lp->stripes_supplied) {
+			log_error("Minimum of 3 stripes required for %s.", lp->segtype->name);
+			return 0;
+		}
+
+		log_warn("Adjusting stripes to the minimum of 3 for %s.", lp->segtype->name);
+		lp->stripes = 3;
+	} else if (lp->stripes < 2) {
+		if (lp->stripes_supplied) {
+			log_error("Minimum of 2 stripes required for %s.", lp->segtype->name);
+			return 0;
+		}
+
+		log_warn("Adjusting stripes to the minimum of 2 for %s.", lp->segtype->name);
+		lp->stripes = 2;
+	}
 
 	if (seg_is_raid1(lp)) {
 		if (lp->stripe_size) {


