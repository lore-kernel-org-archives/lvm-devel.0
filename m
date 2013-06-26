From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:33 +0000 (UTC)
Subject: dev-peter-config-profiles - thin: check for creation of pool
Message-ID: <20130626145533.9A04361131@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4d6f7939c83f2b60be7e892af7588693e651789
Commit:        a4d6f7939c83f2b60be7e892af7588693e651789
Parent:        d46588c2d7b051a69564bd862a5b2579c2cdb8f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 24 20:54:05 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 13:47:39 2013 +0200

thin: check for creation of pool

---
 tools/lvcreate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 43bb3d6..80ca1bc 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -393,12 +393,11 @@ static int _read_size_params(struct lvcreate_params *lp,
 	if (seg_is_thin(lp) && (arg_count(cmd, size_ARG) || arg_count(cmd, extents_ARG)))
 		lp->create_thin_pool = 1;
 
-	if (arg_count(cmd, poolmetadatasize_ARG) && !seg_is_thin(lp)) {
+	if (!lp->create_thin_pool && arg_count(cmd, poolmetadatasize_ARG)) {
 		log_error("--poolmetadatasize may only be specified when allocating the thin pool.");
 		return 0;
 	}
 
-	/* Size returned in kilobyte units; held in sectors */
 	if (arg_count(cmd, virtualsize_ARG)) {
 		if (seg_is_thin_pool(lp)) {
 			log_error("Virtual size in incompatible with thin_pool segment type.");
@@ -408,6 +407,7 @@ static int _read_size_params(struct lvcreate_params *lp,
 			log_error("Negative virtual origin size is invalid");
 			return 0;
 		}
+		/* Size returned in kilobyte units; held in sectors */
 		lp->voriginsize = arg_uint64_value(cmd, virtualsize_ARG,
 						   UINT64_C(0));
 		if (!lp->voriginsize) {


