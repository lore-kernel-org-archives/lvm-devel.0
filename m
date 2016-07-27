From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 27 Jul 2016 16:21:14 +0000 (UTC)
Subject: master - lvcreate.c: respect DEFAULT_RAID_MAX_IMAGES on creation of any RaidLV
Message-ID: <20160727162114.8086960BDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7b2654c25b8953c55638e7fab2cd0268845cbb3
Commit:        c7b2654c25b8953c55638e7fab2cd0268845cbb3
Parent:        8f62b7bfe56c25efbbff5fea26ce29ac6378f08a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jul 27 18:20:48 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jul 27 18:20:48 2016 +0200

lvcreate.c: respect DEFAULT_RAID_MAX_IMAGES on creation of any RaidLV

---
 tools/lvcreate.c |   23 ++++++++---------------
 1 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 88e43e4..1ed39e2 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -529,25 +529,12 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 					struct lvcreate_params *lp)
 {
 	int pagesize = lvm_getpagesize();
-	unsigned max_images;
-	const char *segtype_name;
+	unsigned max_images = segtype_is_raid(lp->segtype) ? DEFAULT_RAID_MAX_IMAGES :
+							     DEFAULT_MIRROR_MAX_IMAGES;
 
 	/* Common mirror and raid params */
 	if (arg_is_set(cmd, mirrors_ARG)) {
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
-		if (segtype_is_raid1(lp->segtype)) {
-			segtype_name = SEG_TYPE_NAME_RAID1;
-			max_images = DEFAULT_RAID_MAX_IMAGES;
-		} else {
-			segtype_name = SEG_TYPE_NAME_MIRROR;
-			max_images = DEFAULT_MIRROR_MAX_IMAGES;
-		}
-
-		if (lp->mirrors > max_images) {
-			log_error("Only up to %u images in %s supported currently.",
-				  max_images, segtype_name);
-			return 0;
-		}
 
 		if ((lp->mirrors > 2) && segtype_is_raid10(lp->segtype)) {
 			/*
@@ -571,6 +558,12 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		/* Default to 2 mirrored areas if '--type mirror|raid1|raid10' */
 		lp->mirrors = seg_is_mirrored(lp) ? 2 : 1;
 
+	if (max(lp->mirrors, lp->stripes) > max_images) {
+		log_error("Only up to %u images in %s supported currently.",
+			  max_images, lp->segtype->name);
+		return 0;
+	}
+
 	lp->nosync = arg_is_set(cmd, nosync_ARG);
 
 	if (!(lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0)) &&


