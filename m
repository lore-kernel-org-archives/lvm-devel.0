From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Sep 2016 12:01:45 +0000 (UTC)
Subject: master - debug: mention origin_only in message
Message-ID: <20160919120145.535486053F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a029123679e183d410189dd90e17d6f5b590a35b
Commit:        a029123679e183d410189dd90e17d6f5b590a35b
Parent:        b3b8834724f445706723b1f1b19ec9bde33faa24
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 19 13:48:54 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 19 14:00:56 2016 +0200

debug: mention origin_only in message

---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1ad85ed..e714f0b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6174,8 +6174,8 @@ static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
 	int do_backup = 0, r = 0;
 	const struct logical_volume *lock_lv = lv_lock_holder(lv);
 
-	log_very_verbose("Updating logical volume %s on disk(s).",
-			 display_lvname(lock_lv));
+	log_very_verbose("Updating logical volume %s on disk(s)%s.",
+			 display_lvname(lock_lv), origin_only ? " (origin only)": "");
 
 	if (!vg_write(vg))
 		return_0;


