From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:37 +0000 (UTC)
Subject: master - cleanup: reorder code
Message-ID: <20140711113437.2D7946056E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9955204e0d9d8d50c19564d475ece03995a6e837
Commit:        9955204e0d9d8d50c19564d475ece03995a6e837
Parent:        de1ee0bc52255987f3b21819a55c0ef9ddf261bb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 7 22:24:35 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:32:21 2014 +0200

cleanup: reorder code

Simplify code.
---
 lib/metadata/thin_manip.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 33ab31c..28b6bbf 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -474,15 +474,15 @@ int update_thin_pool_params(struct volume_group *vg, unsigned attr,
 	}
 
 	if (*pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
 		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
 			log_warn("WARNING: Maximum supported pool metadata size is %s.",
-				 display_size(cmd, 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE));
-		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
+				 display_size(cmd, *pool_metadata_size));
 	} else if (*pool_metadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
+		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
 		if (passed_args & PASS_ARG_POOL_METADATA_SIZE)
 			log_warn("WARNING: Minimum supported pool metadata size is %s.",
-				 display_size(cmd, 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE));
-		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
+				 display_size(cmd, *pool_metadata_size));
 	}
 
 	log_verbose("Setting pool metadata size to %s.",


