From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  1 Aug 2016 15:47:23 +0000 (UTC)
Subject: master - Revert "thin: when converting a thin pool data or metadata LV from"
Message-ID: <20160801154723.8E60160B61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c490be9134a3c571636ab67d99ffeeac27d9b56f
Commit:        c490be9134a3c571636ab67d99ffeeac27d9b56f
Parent:        d0df1ff995f3270232ec5179057482c558119a92
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 1 15:17:44 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 1 15:17:44 2016 +0100

Revert "thin: when converting a thin pool data or metadata LV from"

This reverts commit 237f84e0383c7e3003050be7c072ee0a092fd426.

This case failed:
    lvcreate --type raid1 -m1 -l2 vg99
    lvcreate -aey -l2 -s vg99/lvol0
    lvconvert -m2 vg99/lvol0
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 6ac7450..0364f2f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -862,7 +862,7 @@ to be left for these sub-lvs.
 	dm_list_iterate_items(lvl, &data_lvs)
 		lv_set_hidden(lvl->lv);
 
-	if (!lv_update_and_reload(lv))
+	if (!lv_update_and_reload_origin(lv))
 		return_0;
 
 	/*


