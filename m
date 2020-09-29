From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 29 Sep 2020 08:45:20 +0000 (GMT)
Subject: master - cleanup: avoid unneeded check
Message-ID: <20200929084520.A0AB83861812@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=08e838f488415ce6c7df594327c383cdc7c2dcd7
Commit:        08e838f488415ce6c7df594327c383cdc7c2dcd7
Parent:        af5f29c7e2f07005462d505c57a2f1440c9d50a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 26 19:32:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 29 10:43:56 2020 +0200

cleanup: avoid unneeded check

Since creation of thin snapshot already makes sure,
the message list is empty, there is no need to check
this again.
---
 lib/metadata/lv_manip.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ce532ab92..793a86d1f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8482,8 +8482,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				stack;
 				goto revert_new_lv;
 			}
-		}
-		if (!dm_list_empty(&first_seg(pool_lv)->thin_messages)) {
+		} else if (!dm_list_empty(&first_seg(pool_lv)->thin_messages)) {
 			/* Send message so that table preload knows new thin */
 			if (!lv_is_active(pool_lv)) {
 				/* Avoid multiple thin-pool activations in this case */


