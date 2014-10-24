From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:47 +0000 (UTC)
Subject: master - cleanup: lv_manip drops duplicated internal error
Message-ID: <20141024144047.3DC0960CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37bd12e7ba60e5e6654d7edd912d011328401a21
Commit:        37bd12e7ba60e5e6654d7edd912d011328401a21
Parent:        958cae8fd8e03a1b3d060c07d49953bbdc419b9c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 23 12:40:15 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cleanup: lv_manip drops duplicated internal error

No reason to check the same condition twice with internal error.
---
 lib/metadata/lv_manip.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 54fc6a8..fe0eead 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3717,11 +3717,6 @@ int lv_extend(struct logical_volume *lv,
 		new_extents -= ah->log_len * ah->area_multiple;
 
 	if (segtype_is_thin_pool(segtype) || segtype_is_cache_pool(segtype)) {
-		if (lv->le_count) {
-			/* lv_resize abstracts properly _tdata */
-			log_error(INTERNAL_ERROR "Cannot lv_extend() the existing %s segment.", segtype->name);
-			return 0;
-		}
 		if (!(r = create_pool(lv, segtype, ah, stripes, stripe_size)))
 			stack;
 	} else if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype)) {


