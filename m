From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:33 +0000 (UTC)
Subject: master - cleanup: just switch error path
Message-ID: <20160505220133.8031660C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6575ec824964ee2f830746e12b12a887c95e7f7
Commit:        f6575ec824964ee2f830746e12b12a887c95e7f7
Parent:        d1ecbfa52d3f35c8702ca50f30577daa8c324eb9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 5 23:12:30 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:52:06 2016 +0200

cleanup: just switch error path

Check for error case in if() like we normally do.
Let code continue on success.
---
 lib/metadata/lv_manip.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 45dd1f5..9bfef45 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7771,16 +7771,16 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
 				return_NULL;
 
-			if (lv_is_cache(lv)) {
-				/* Here it's been converted via lvcreate */
-				log_print_unless_silent("Logical volume %s is now cached.",
-							display_lvname(lv));
-				return lv;
+			if (!lv_is_cache(lv)) {
+				log_error(INTERNAL_ERROR "Logical volume is not cache %s.",
+					  display_lvname(lv));
+				return NULL;
 			}
 
-			log_error(INTERNAL_ERROR "Logical volume is not cache %s.",
-				  display_lvname(lv));
-			return NULL;
+			/* Convertion via lvcreate */
+			log_print_unless_silent("Logical volume %s is now cached.",
+						display_lvname(lv));
+			return lv;
 		} else {
 			log_error(INTERNAL_ERROR "Creation of pool for unsupported segment type %s.",
 				  lp->segtype->name);


