From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 28 Sep 2015 20:41:12 +0000 (UTC)
Subject: master - raid: Introduce DEFAULT_RAID_MAX_IMAGES
Message-ID: <20150928204112.DBC3C60AAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be393f6722bd89f3fe98ab1be2f1dd41609a0172
Commit:        be393f6722bd89f3fe98ab1be2f1dd41609a0172
Parent:        d94ff2092709c600524f732b8bc98cd692562bcb
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Sep 28 21:38:40 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 28 21:38:40 2015 +0100

raid: Introduce DEFAULT_RAID_MAX_IMAGES

Prepare to allow for the number of images in a raid set to be
larger than the limit for old-style dm raid1.
---
 lib/config/defaults.h |    2 ++
 tools/lvcreate.c      |   15 ++++++++++++---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index f84eb19..cd5d121 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -63,6 +63,8 @@
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
+#define DEFAULT_RAID_MAX_IMAGES 8
+
 #define DEFAULT_RAID_FAULT_POLICY "warn"
 
 #define DEFAULT_DMEVENTD_RAID_LIB "libdevmapper-event-lvm2raid.so"
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 80c336a..0debf40 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -500,14 +500,23 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 					struct lvcreate_params *lp)
 {
 	int pagesize = lvm_getpagesize();
+	unsigned max_images;
+	const char *segtype_name;
 
 	/* Common mirror and raid params */
 	if (arg_count(cmd, mirrors_ARG)) {
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
+		if (segtype_is_raid1(lp->segtype)) {
+			segtype_name = SEG_TYPE_NAME_RAID1;
+			max_images = DEFAULT_RAID_MAX_IMAGES;
+		} else {
+			segtype_name = SEG_TYPE_NAME_MIRROR;
+			max_images = DEFAULT_MIRROR_MAX_IMAGES;
+		}
 
-		if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
-			log_error("Only up to " DM_TO_STRING(DEFAULT_MIRROR_MAX_IMAGES)
-				  " images in mirror supported currently.");
+		if (lp->mirrors > max_images) {
+			log_error("Only up to %u images in %s supported currently.",
+				  max_images, segtype_name);
 			return 0;
 		}
 


