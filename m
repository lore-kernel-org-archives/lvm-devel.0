From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:16 +0000 (UTC)
Subject: master - lvcreate: move tests that requires activation
Message-ID: <20141024144016.041D560317@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a2f553b7d5f516ac750aadd4ca75cc4a20aef15
Commit:        8a2f553b7d5f516ac750aadd4ca75cc4a20aef15
Parent:        f7cfea251c07b3a63131320cf4751b91480b9be7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 21 12:12:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

lvcreate: move tests that requires activation

Tests that needs active kernel driver put in single place.
---
 lib/metadata/lv_manip.c |   48 ++++++++++++++++++++++++----------------------
 1 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6caa284..61620e5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6590,6 +6590,31 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return NULL;
 	}
 
+	if (!activation()) {
+		if (seg_is_cache(lp) ||
+		    seg_is_mirror(lp) ||
+		    seg_is_raid(lp) ||
+		    seg_is_thin(lp) ||
+		    lp->snapshot) {
+			/*
+			 * FIXME: For thin pool add some code to allow delayed
+			 * initialization of empty thin pool volume.
+			 * i.e. using some LV flag, fake message,...
+			 * and testing for metadata pool header signature?
+			 */
+			log_error("Can't create %s without using "
+				  "device-mapper kernel driver.",
+				  lp->segtype->name);
+			return NULL;
+		}
+		/* Does LV need to be zeroed? */
+		if (lp->zero && !seg_is_thin(lp)) {
+			log_error("Can't wipe start of new LV without using "
+				  "device-mapper kernel driver.");
+			return NULL;
+		}
+	}
+
 	if (lp->stripe_size > vg->extent_size) {
 		if (segtype_is_raid(lp->segtype) &&
 		    (vg->extent_size < STRIPE_SIZE_MIN)) {
@@ -6629,13 +6654,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lp->extents = lp->extents - size_rest + lp->stripes;
 	}
 
-	/* Does LV need to be zeroed?  Thin handles this as a per-pool in-kernel setting. */
-	if (lp->zero && !segtype_is_thin(lp->segtype) && !activation()) {
-		log_error("Can't wipe start of new LV without using "
-			  "device-mapper kernel driver");
-		return NULL;
-	}
-
 	status |= lp->permission | VISIBLE_LV;
 
 	if (seg_is_cache(lp)) {
@@ -6773,22 +6791,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return NULL;
 	}
 
-	if (!activation() &&
-	    (seg_is_mirrored(lp) ||
-	     seg_is_raid(lp) ||
-	     seg_is_pool(lp))) {
-		/*
-		 * FIXME: For thin pool add some code to allow delayed
-		 * initialization of empty thin pool volume.
-		 * i.e. using some LV flag, fake message,...
-		 * and testing for metadata pool header signature?
-		 */
-		log_error("Can't create %s without using "
-			  "device-mapper kernel driver.",
-			  lp->segtype->name);
-		return NULL;
-	}
-
 	/* The snapshot segment gets created later */
 	if (lp->snapshot && !seg_is_thin(lp) &&
 	    !(lp->segtype = get_segtype_from_string(cmd, "striped")))


