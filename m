From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Sep 2020 21:07:07 +0000 (GMT)
Subject: master - thin: pass through whole code
Message-ID: <20200925210707.39179385782E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e414ebef6ece7c89f539f3ca01ad45a0c021575f
Commit:        e414ebef6ece7c89f539f3ca01ad45a0c021575f
Parent:        2bfa868f911b83f308c0fa3a09751f5b1cbddcfa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 25 14:34:49 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 25 22:59:35 2020 +0200

thin: pass through whole code

Instead of early 'return 0' let the whole code finish
in case of an error with syncing.
---
 lib/metadata/thin_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 588707961..e3364ddc8 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -532,7 +532,7 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 		if (!sync_local_dev_names(lv->vg->cmd)) {
 			log_error("Failed to sync local devices LV %s.",
 				  display_lvname(lv));
-			return 0;
+			ret = 0;
 		}
 
 		if (activate &&


