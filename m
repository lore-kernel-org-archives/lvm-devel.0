From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  2 Aug 2016 15:46:20 +0000 (UTC)
Subject: master - lvconvert: Divide into 12 categories.
Message-ID: <20160802154620.CD33B605CC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=415c5fd5d8e58b34fd016ba1e45dc43c6ed10e18
Commit:        415c5fd5d8e58b34fd016ba1e45dc43c6ed10e18
Parent:        6361bc4734f2227f049cb6ef0335f30468c2775d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 2 16:40:33 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 2 16:44:21 2016 +0100

lvconvert: Divide into 12 categories.

---
 tools/lvconvert.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6c57191..8444b35 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -38,12 +38,10 @@
  */
 
 struct lvconvert_params {
-	/* Exactly one of these options is chosen */
+	/* Exactly one of these 12 command categories is determined */
 	int merge;		/* Either merge_snapshot or merge_mirror is also set */
 	int cache;
-	int corelog;
-	int mirrorlog;
-	int mirrors_supplied;	/* When type_str is not set, this may be set with keep_mimages for --splitmirrors */
+	int keep_mimages;	/* --splitmirrors */
 	int repair;
 	int replace;
 	int snapshot;
@@ -52,6 +50,12 @@ struct lvconvert_params {
 	int splitsnapshot;
 	int thin;
 	int uncache;
+	int other_conversion;	/* Everything else */
+
+	int corelog;		/* Equivalent to --mirrorlog core */
+	int mirrorlog;		/* Only one of corelog and mirrorlog may be set */
+
+	int mirrors_supplied;	/* When type_str is not set, this may be set with keep_mimages for --splitmirrors */
 	const char *type_str;	/* When this is set, mirrors_supplied may optionally also be set */
 				/* Holds what you asked for based on --type or other arguments, else "" */
 
@@ -80,7 +84,6 @@ struct lvconvert_params {
 
 	uint32_t mirrors;
 	sign_t mirrors_sign;
-	uint32_t keep_mimages;	/* --splitmirrors */
 	uint32_t stripes;
 	uint32_t stripe_size;
 	uint32_t read_ahead;
@@ -629,7 +632,8 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	    lp->cache + lp->thin + lp->keep_mimages + lp->snapshot + lp->replace + lp->repair > 1) {
 		log_error(INTERNAL_ERROR "Unexpected combination of incompatible options selected.");
 		return 0;
-	}
+	} else
+		lp->other_conversion = 1;
 
 	/*
 	 * Final checking of each case:


