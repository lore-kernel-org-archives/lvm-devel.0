From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:23:13 -0500
Subject: master - lv_manip: add extra check for existin origin_lv
Message-ID: <19785.120020411230901175@us-mta-277.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=336361b2f25c09c7aad4d21aca272a11c6c9352a
Commit:        336361b2f25c09c7aad4d21aca272a11c6c9352a
Parent:        67f627c8fbcd5224a1439cbef590e488f6c4823b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 30 15:54:19 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

lv_manip: add extra check for existin origin_lv

clang: it's supposedly impossible path to hit, as we should always
have origin_lv defined when running this path, but adding protection
isn't a big issue to make this obvious to analyzer.
---
 lib/metadata/lv_manip.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ad9c756..c9f7348 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8372,7 +8372,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		 * COW LV is activated via implicit activation of origin LV
 		 * Only the snapshot origin holds the LV lock in cluster
 		 */
-		if (!vg_add_snapshot(origin_lv, lv, NULL,
+		if (!origin_lv ||
+		    !vg_add_snapshot(origin_lv, lv, NULL,
 				     origin_lv->le_count, lp->chunk_size)) {
 			log_error("Couldn't create snapshot.");
 			goto deactivate_and_revert_new_lv;



