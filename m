From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 21 Jun 2017 18:50:33 -0400
Subject: master - raid: fix segfault
Message-ID: <201706212250.v5LMoXTD014562@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=64fac77e8a551f4dfe8f4cfaaf1ca984c9b5146c
Commit:        64fac77e8a551f4dfe8f4cfaaf1ca984c9b5146c
Parent:        93fbfa2ed397d7b87d4088e19303748c242f24d1
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jun 22 00:49:00 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Jun 22 00:49:00 2017 +0200

raid: fix segfault

Add missing else clause
(already missing in initial commit fe18e5e77a488618510648c7801ea3375ce5aac4).

Resolves: rhbz1463794
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9e4f3a3..66fc2bd 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2373,7 +2373,7 @@ static int _raid_reshape(struct logical_volume *lv,
 	if (seg->area_count != 2 || old_image_count != seg->area_count) {
 		if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
 			return_0;
-	} if (!_vg_write_commit_backup(lv->vg))
+	} else if (!_vg_write_commit_backup(lv->vg))
 		return_0;
 
 	return 1; 


