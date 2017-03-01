From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 1 Mar 2017 09:04:53 -0500
Subject: master - raid: rework _raid_target_present()
Message-ID: <201703011404.v21E4rbu006984@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6dd700bf75d218a6f7627451d020232d3d88c31
Commit:        d6dd700bf75d218a6f7627451d020232d3d88c31
Parent:        7a064303fe1a14e205a50abc5a54e38467fcb455
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Mar 1 14:52:23 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Mar 1 14:52:23 2017 +0100

raid: rework _raid_target_present()

Recently added check for reshaping in this function called for
a cleanup to avoid proliferating it with more explicit conditionals.

Base the reshaping check on the given _features array.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/raid/raid.c |   43 +++++++++++++++++++++++++++++--------------
 1 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 6815454..6439a3e 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -448,19 +448,32 @@ out:
 	return r;
 }
 
+/* Define raid feature based on the tuple(major, minor, patchlevel) of raid target */
+struct raid_feature {
+	uint32_t maj;
+	uint32_t min;
+	uint32_t patchlevel;
+	unsigned raid_feature;
+	const char *feature;
+};
+
+/* Return true if tuple(@maj, @min, @patchlevel) is greater/equal to @*feature members */
+static int _check_feature(const struct raid_feature *feature, uint32_t maj, uint32_t min, uint32_t patchlevel)
+{
+	return (maj > feature->maj) ||
+	       (maj == feature->maj && min >= feature->min) ||
+	       (maj == feature->maj && min == feature->min && patchlevel >= feature->patchlevel);
+}
+
 static int _raid_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg __attribute__((unused)),
 				unsigned *attributes)
 {
 	/* List of features with their kernel target version */
-	static const struct feature {
-		uint32_t maj;
-		uint32_t min;
-		unsigned raid_feature;
-		const char *feature;
-	} _features[] = {
-		{ 1, 3, RAID_FEATURE_RAID10, SEG_TYPE_NAME_RAID10 },
-		{ 1, 7, RAID_FEATURE_RAID0, SEG_TYPE_NAME_RAID0 },
+	const struct raid_feature _features[] = {
+		{ 1, 3, 0, RAID_FEATURE_RAID10, SEG_TYPE_NAME_RAID10 },
+		{ 1, 7, 0, RAID_FEATURE_RAID0, SEG_TYPE_NAME_RAID0 },
+		{ 1, 10, 1, RAID_FEATURE_RESHAPE, "reshaping" },
 	};
 
 	static int _raid_checked = 0;
@@ -482,22 +495,24 @@ static int _raid_target_present(struct cmd_context *cmd,
 			return_0;
 
 		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
-			if ((maj > _features[i].maj) ||
-			    (maj == _features[i].maj && min >= _features[i].min))
+			if (_check_feature(_features + i, maj, min, patchlevel))
 				_raid_attrs |= _features[i].raid_feature;
 			else
 				log_very_verbose("Target raid does not support %s.",
 						 _features[i].feature);
 
+		/*
+		 * Seperate check for proper raid4 mapping supported
+		 *
+		 * If we get more of these range checks, avoid them
+		 * altogether by enhancing 'struct raid_feature'
+		 * and _check_feature() to handle them.
+		 */
 		if (!(maj == 1 && (min == 8 || (min == 9 && patchlevel == 0))))
 			_raid_attrs |= RAID_FEATURE_RAID4;
 		else
 			log_very_verbose("Target raid does not support %s.",
 					 SEG_TYPE_NAME_RAID4);
-
-		if (maj > 1 ||
-		    (maj == 1 && (min > 10 || (min == 10 && patchlevel >= 1))))
-			_raid_attrs |= RAID_FEATURE_RESHAPE;
 	}
 
 	if (attributes)


