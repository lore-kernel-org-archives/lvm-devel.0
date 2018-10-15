From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:54:51 -0400
Subject: master - cov: drop check for pointer
Message-ID: <201810151554.w9FFspO6020459@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fbfbbf6d6a4c27d1a9965c196cf625a49223eccd
Commit:        fbfbbf6d6a4c27d1a9965c196cf625a49223eccd
Parent:        1bb30a8c27ce73433748b49b5478e6ce2b7d4703
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:19:22 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 14:24:28 2018 +0200

cov: drop check for pointer

Pointer must be always set and it's been already dereferenced.
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 1af3729..3944dc4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2243,7 +2243,7 @@ static int _vg_write_lv_suspend_commit_backup(struct volume_group *vg,
 		return_0;
 	}
 
-	if (lv && !(r = (origin_only ? suspend_lv_origin(vg->cmd, lock_lv) :
+	if (!(r = (origin_only ? suspend_lv_origin(vg->cmd, lock_lv) :
 				       suspend_lv(vg->cmd, lock_lv)))) {
 		log_error("Failed to suspend %s before committing changes.",
 			  display_lvname(lv));


