From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 25 Nov 2016 14:04:10 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20161125140410.D9F4E60BAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=108d9a63fde1608aff815359d58da641fc9a18af
Commit:        108d9a63fde1608aff815359d58da641fc9a18af
Parent:        c10028dd8eb5d2302dfa588bbae034eb24d710cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 25 14:21:34 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 25 15:01:28 2016 +0100

cleanup: indent

---
 lib/metadata/lv_manip.c   |    1 +
 lib/metadata/raid_manip.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 615632d..10c0446 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1033,6 +1033,7 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 				return 0;
 			}
 		}
+
 		return 1;
 	}
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0793017..9c8ba82 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3662,13 +3662,13 @@ static int _set_convenient_raid456_segtype_to(const struct lv_segment *seg_from,
 	/* Got to do check for raid5 -> raid6 ... */
 	} else if (seg_is_any_raid5(seg_from) &&
 		   segtype_is_any_raid6(*segtype)) {
-			log_error("Conversion not supported.");
+		log_error("Conversion not supported.");
 		return 0;
 
 	/* ... and raid6 -> raid5 */
 	} else if (seg_is_any_raid6(seg_from) &&
 		   segtype_is_any_raid5(*segtype)) {
-			log_error("Conversion not supported.");
+		log_error("Conversion not supported.");
 		return 0;
 	}
 


