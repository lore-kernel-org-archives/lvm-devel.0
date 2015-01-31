From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat, 31 Jan 2015 14:10:30 +0000 (UTC)
Subject: dev-lvmguy-raid-takeover-reshape-resize - make coverity happy in __avoid_pvs_with_other_images_of_lv()
Message-ID: <20150131141030.BEBCB601E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b8e9454601b32c6689045777db2c605084e27e74
Commit:        b8e9454601b32c6689045777db2c605084e27e74
Parent:        f8e0b7b75afd379b69bc9efb0b2767b5a139a132
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jan 22 13:49:04 2015 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Jan 22 13:49:04 2015 +0100

make coverity happy in __avoid_pvs_with_other_images_of_lv()

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index cf0de89..e6367c4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2765,7 +2765,7 @@ static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
  */
 static void __avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
 {
-	for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
+	(void) for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
 }
 
 /*


