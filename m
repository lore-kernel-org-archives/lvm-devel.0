From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 Sep 2020 21:21:17 +0000 (GMT)
Subject: master - wipe: zeroing of 8 sectors is granted
Message-ID: <20200915212117.56399397249F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ec4e8b5c0e33faed644e3a8b0f038181cfc69de3
Commit:        ec4e8b5c0e33faed644e3a8b0f038181cfc69de3
Parent:        7bcc99477638eee4c813acf1ca60233ed0c6bb61
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 15 16:38:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 15 22:52:25 2020 +0200

wipe: zeroing of 8 sectors is granted

With do_zero min is always 8 sectors, so use 0 as default.
---
 lib/metadata/integrity_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 42e6d936e..00d310e36 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -533,7 +533,7 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 	 */
 	for (s = 0; s < area_count; s++) {
 		struct logical_volume *meta_lv;
-		struct wipe_params wipe = { .do_zero = 1, .zero_sectors = 8 };
+		struct wipe_params wipe = { .do_zero = 1 };
 
 		if (s >= DEFAULT_RAID_MAX_IMAGES)
 			goto_bad;


