From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:04 +0000 (UTC)
Subject: master - raid: typo
Message-ID: <20170224063204.DFE1A60AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1865b0a864e0623b2395c96e7853e4637e46772
Commit:        c1865b0a864e0623b2395c96e7853e4637e46772
Parent:        b499d96215a67711220b44fcb88693221c6d7ef5
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 01:29:37 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

raid: typo

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9c94b24..70e0a55 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -434,7 +434,7 @@ static int _lv_update_and_reload_list(struct logical_volume *lv, int origin_only
 			  display_lvname(lock_lv));
 		vg_revert(vg);
 	} else if (!(r = vg_commit(vg)))
-		stack; /* !vg_commit() has implict vg_revert() */
+		stack; /* !vg_commit() has implicit vg_revert() */
 
 	if (r && lv_list) {
 		dm_list_iterate_items(lvl, lv_list) {


