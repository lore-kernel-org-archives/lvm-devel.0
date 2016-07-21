From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 21 Jul 2016 00:33:38 +0000 (UTC)
Subject: master - lvcreate: conditionally set stripesize
Message-ID: <20160721003338.B2FAF60B3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=259f9dd71817ad33195384dbeca14b39dfb77ae1
Commit:        259f9dd71817ad33195384dbeca14b39dfb77ae1
Parent:        b203d5e745ae779c5686868f1b4c461916ef73b9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jul 21 02:32:39 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Jul 21 02:33:28 2016 +0200

lvcreate: conditionally set stripesize

Stripe size may not be set unconditionally in
_read_mirror_and_raid_params() or creation of
striped LV will fail
---
 tools/lvcreate.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8436365..a365fe9 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -486,7 +486,7 @@ static int _read_raid_params(struct cmd_context *cmd,
 		}
 
 	} else if (lp->stripes < 2)
-		/* No stripe argument was given */
+		/* No stripes argument was given */
 		lp->stripes = seg_is_any_raid6(lp) ? 3 : 2;
 
 	if (seg_is_raid1(lp)) {
@@ -577,7 +577,8 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
+	if (arg_is_set(cmd, stripesize_ARG))
+		lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
 
 	if (!is_power_of_2(lp->region_size)) {
 		log_error("Region size (%" PRIu32 ") must be a power of 2",


