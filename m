From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 12:49:18 -0400
Subject: master - debug: add missing internal error message
Message-ID: <201706231649.v5NGnIBD019885@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7c7d53543c37e9a3366b88399d4f7c8be2ddf58
Commit:        a7c7d53543c37e9a3366b88399d4f7c8be2ddf58
Parent:        1bdcd156fdbd007bc6c31ec4077d8215baf5a0af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 14:41:10 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:44:01 2017 +0200

debug: add missing internal error message

Do not just 'return_0'  log error would need to be shown.
---
 lib/metadata/raid_manip.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 6bd0fb2..74fafa3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6090,8 +6090,11 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, con
 		return_0;
 
 	/* CLI validation provides the check but be caucious... */
-	if (!lv_is_raid(lv) || !seg || seg_is_any_raid0(seg))
-		return_0;
+	if (!lv_is_raid(lv) || !seg || seg_is_any_raid0(seg)) {
+		log_error(INTERNAL_ERROR "Cannot change region size of %s.",
+			  display_lvname(lv));
+		return 0;
+	}
 
 	if (region_size == seg->region_size) {
 		log_error("Region size is already %s on %s LV %s.",


