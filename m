From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 15 Aug 2016 18:42:24 +0000 (UTC)
Subject: master - tools: Suppress some unnecessary --stripesize warnings.
Message-ID: <20160815184224.13C77614D4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=114db6f745a229e1c3bf2dc95cc45c020cbcfca8
Commit:        114db6f745a229e1c3bf2dc95cc45c020cbcfca8
Parent:        d83f2d766d3177e2d2509f4fddb9b6f9c7fac7bc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 15 19:38:45 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 15 19:38:45 2016 +0100

tools: Suppress some unnecessary --stripesize warnings.

https://bugzilla.redhat.com/1366745
---
 WHATS_NEW       |    1 +
 tools/toollib.c |    8 +++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 60bdc4f..ae6bbea 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Suppress some unnecessary --stripesize parameter warnings.
   Fix 'pvmove -n name ...' to prohibit collocation of RAID SubLVs
 
 Version 2.02.164 - 15th August 2016
diff --git a/tools/toollib.c b/tools/toollib.c
index e24946f..4f8cbb4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1281,10 +1281,12 @@ static int _validate_stripe_params(struct cmd_context *cmd, const struct segment
 	if (!stripe_size_required && *stripe_size) {
 		log_print_unless_silent("Ignoring stripesize argument for %s devices.", segtype->name);
 		*stripe_size = 0;
-	} else if (segtype_is_striped(segtype) && *stripes == 1 && *stripe_size) {
-		log_print_unless_silent("Ignoring stripesize argument with single stripe.");
+	} else if (*stripes == 1 && (segtype_is_striped(segtype) || segtype_is_mirror(segtype))) {
 		stripe_size_required = 0;
-		*stripe_size = 0;
+		if (*stripe_size) {
+			log_print_unless_silent("Ignoring stripesize argument with single stripe.");
+			*stripe_size = 0;
+		}
 	}
 
 	if (stripe_size_required) {


