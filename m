From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 18:29:34 -0400
Subject: master - cleanup: remove unused code
Message-ID: <201706262229.v5QMTYjq010125@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e331c8e68d5f80cacc194625ad97ee4c26fc3ee
Commit:        3e331c8e68d5f80cacc194625ad97ee4c26fc3ee
Parent:        ab6f4649a0d533b84a7496d88acefa318212d162
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 26 23:19:57 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 00:27:25 2017 +0200

cleanup: remove unused code

---
 lib/metadata/raid_manip.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 158bcf2..774924a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2163,12 +2163,6 @@ static int _vg_write_commit_backup(struct volume_group *vg)
 	return 1;
 }
 
-__attribute__ ((__unused__))
-static int _vg_write_commit(struct volume_group *vg)
-{
-	return _vg_write_lv_suspend_commit_backup(vg, NULL, 1, 0);
-}
-
 /* Write vg of @lv, suspend @lv and commit the vg */
 static int _vg_write_lv_suspend_vg_commit(struct logical_volume *lv, int origin_only)
 {


