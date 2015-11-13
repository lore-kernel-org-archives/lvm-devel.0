From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:06 +0000 (UTC)
Subject: master - raid: ensure area_count is at least 2
Message-ID: <20151113101906.ADB50610A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=007be91e3d128320c290fc404532d1d691212b88
Commit:        007be91e3d128320c290fc404532d1d691212b88
Parent:        d74e1291cd43f50010c22fb2c071d92390a26d28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 13 10:59:58 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:17:06 2015 +0100

raid: ensure area_count is at least 2

Enusure we will not divide by 0.
---
 lib/metadata/raid_manip.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ee1f2be..4b2cb61 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -460,9 +460,14 @@ static int _alloc_image_components(struct logical_volume *lv,
 	 * individual devies, we must specify how large the individual device
 	 * is along with the number we want ('count').
 	 */
-	if (segtype_is_raid10(segtype))
+	if (segtype_is_raid10(segtype)) {
+		if (seg->area_count < 2) {
+			log_error(INTERNAL_ERROR "LV %s needs@least 2 areas.",
+				  display_lvname(lv));
+			return 0;
+		}
 		extents = lv->le_count / (seg->area_count / 2); /* we enforce 2 mirrors right now */
-	else
+	} else
 		extents = (segtype->parity_devs) ?
 			   (lv->le_count / (seg->area_count - segtype->parity_devs)) :
 			   lv->le_count;


