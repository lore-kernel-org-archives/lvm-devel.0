From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:50 +0000 (GMT)
Subject: stable-2.02 - thin: pass through whole code
Message-ID: <20201016191150.F1BE8396EC6B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a0f9537f14267bae4153deb9160ae2d75623829
Commit:        8a0f9537f14267bae4153deb9160ae2d75623829
Parent:        3a2ada80cb9f8982c91772a0bb4309027dcb8b2b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 25 14:34:49 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

thin: pass through whole code

Instead of early 'return 0' let the whole code finish
in case of an error with syncing.
---
 lib/metadata/thin_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 02a97d588..db2644a05 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -534,7 +534,7 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 		if (!sync_local_dev_names(lv->vg->cmd)) {
 			log_error("Failed to sync local devices LV %s.",
 				  display_lvname(lv));
-			return 0;
+			ret = 0;
 		}
 
 		if (activate &&


