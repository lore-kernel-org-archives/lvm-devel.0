From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:41 +0000 (UTC)
Subject: master - lvcreate: validate sizes
Message-ID: <20141006133341.22A1561041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57a52e787843ce1f370f7e60d2f75f78d9f03d54
Commit:        57a52e787843ce1f370f7e60d2f75f78d9f03d54
Parent:        a0693da97f6873b08d33f8c44baacde77e28e33a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 13:54:34 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:07 2014 +0200

lvcreate: validate sizes

Earlier validation of --size and --extents.
Reject 0 size on command line instantly.
---
 tools/lvcreate.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 0a0ce1d..97c8d94 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -506,20 +506,26 @@ static int _read_size_params(struct lvcreate_params *lp,
 
 	if (arg_count(cmd, extents_ARG)) {
 		if (arg_sign_value(cmd, extents_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative number of extents is invalid");
+			log_error("Negative number of extents is invalid.");
+			return 0;
+		}
+		if (!(lp->extents = arg_uint_value(cmd, extents_ARG, 0))) {
+			log_error("Number of extents may not be zero.");
 			return 0;
 		}
-		lp->extents = arg_uint_value(cmd, extents_ARG, 0);
 		lcp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
 	}
 
 	/* Size returned in kilobyte units; held in sectors */
 	if (arg_count(cmd, size_ARG)) {
 		if (arg_sign_value(cmd, size_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative size is invalid");
+			log_error("Negative size is invalid.");
+			return 0;
+		}
+		if (!(lcp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0)))) {
+			log_error("Size may not be zero.");
 			return 0;
 		}
-		lcp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
 		lcp->percent = PERCENT_NONE;
 	}
 


