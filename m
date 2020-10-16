From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:54 +0000 (GMT)
Subject: stable-2.02 - cleanup: avoid unneeded check
Message-ID: <20201016191154.67BE4396EC94@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3094c423a0832c703406be3847d561226c19ea10
Commit:        3094c423a0832c703406be3847d561226c19ea10
Parent:        6373a8497776909b548fb5dcfb332b6502868f99
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 26 19:32:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

cleanup: avoid unneeded check

Since creation of thin snapshot already makes sure,
the message list is empty, there is no need to check
this again.
---
 lib/metadata/lv_manip.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index dbfb306de..341cbbff4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8017,8 +8017,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				stack;
 				goto revert_new_lv;
 			}
-		}
-		if (!dm_list_empty(&first_seg(pool_lv)->thin_messages)) {
+		} else if (!dm_list_empty(&first_seg(pool_lv)->thin_messages)) {
 			/* Send message so that table preload knows new thin */
 			if (!lv_is_active(pool_lv)) {
 				/* Avoid multiple thin-pool activations in this case */


