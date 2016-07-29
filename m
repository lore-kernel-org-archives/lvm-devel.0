From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 29 Jul 2016 17:17:34 +0000 (UTC)
Subject: master - thin: when converting a thin pool data or metadata LV from linear to raid1, the linear wasnt't switched to the raid1 mapping, thus creating the false impression of resilience.
Message-ID: <20160729171734.223EB61A84@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=237f84e0383c7e3003050be7c072ee0a092fd426
Commit:        237f84e0383c7e3003050be7c072ee0a092fd426
Parent:        6b6e258e0ce1c0ab58fc5a465d2617505bc7c814
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jul 29 19:17:12 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jul 29 19:17:12 2016 +0200

thin: when converting a thin pool data or metadata LV from       linear to raid1, the linear wasnt't switched to the       raid1 mapping, thus creating the false impression of       resilience.

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0364f2f..6ac7450 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -862,7 +862,7 @@ to be left for these sub-lvs.
 	dm_list_iterate_items(lvl, &data_lvs)
 		lv_set_hidden(lvl->lv);
 
-	if (!lv_update_and_reload_origin(lv))
+	if (!lv_update_and_reload(lv))
 		return_0;
 
 	/*


