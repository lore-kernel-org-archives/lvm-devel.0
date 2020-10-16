From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:38 +0000 (GMT)
Subject: stable-2.02 - lvcreate: add extra synchronization at error path
Message-ID: <20201016191138.5831F396EC8C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=238da8ddd9c7dd9e9c9413564d67e8bd7055b4ec
Commit:        238da8ddd9c7dd9e9c9413564d67e8bd7055b4ec
Parent:        b490cddfbcd6f4add64303fcd81751f98f086d4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 4 18:08:59 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

lvcreate: add extra synchronization at error path

Put explict udev synchronization before we try to deactive devices.
---
 lib/metadata/lv_manip.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cbd4798ac..63ed182bd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8150,6 +8150,9 @@ out:
 	return lv;
 
 deactivate_and_revert_new_lv:
+	if (!sync_local_dev_names(lv->vg->cmd))
+		log_error("Failed to sync local devices before reverting %s.",
+			  display_lvname(lv));
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate failed new LV %s. "
 			  "Manual intervention required.",  display_lvname(lv));


