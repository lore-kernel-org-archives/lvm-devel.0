From: David Teigland <teigland@sourceware.org>
Date: Thu, 6 Feb 2020 12:29:21 -0500
Subject: master - writecache: prevent snapshots
Message-ID: <41440.120020612291501847@us-mta-38.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ffea7daec3d09fb4315104bb346cfa9d6db6f9e9
Commit:        ffea7daec3d09fb4315104bb346cfa9d6db6f9e9
Parent:        2a6078f96168e860474b42c42b1924fc353c4558
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 6 11:27:33 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 6 11:27:33 2020 -0600

writecache: prevent snapshots

there appear to be problems with taking a snapshot
of an LV with a writecache, so block it until that
is understood or fixed.
---
 lib/metadata/snapshot_manip.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index e58aea4..64e27ae 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -385,8 +385,11 @@ int validate_snapshot_origin(const struct logical_volume *origin_lv)
 			log_warn("WARNING: Consider using the raid1 mirror type to avoid this.");
 			log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
 		}
-	} else if (lv_is_raid_type(origin_lv) && !lv_is_raid(origin_lv))
+	} else if (lv_is_raid_type(origin_lv) && !lv_is_raid(origin_lv)) {
 		err = "raid subvolumes";
+	} else if (lv_is_writecache(origin_lv)) {
+		err = "writecache";
+	}
 
 	if (err) {
 		log_error("Snapshots of %s are not supported.", err);



