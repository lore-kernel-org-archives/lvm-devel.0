From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 Sep 2020 21:21:11 +0000 (GMT)
Subject: master - lvcreate: add extra synchronization at error path
Message-ID: <20200915212111.A07513857828@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39198eb2cebb6a45e148d554d1ed474bda5cbbde
Commit:        39198eb2cebb6a45e148d554d1ed474bda5cbbde
Parent:        18a60c634094273b92182734ceb2013817c497ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 4 18:08:59 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 15 22:52:25 2020 +0200

lvcreate: add extra synchronization at error path

Put explict udev synchronization before we try to deactive devices.
---
 lib/metadata/lv_manip.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d1389d725..e3a1cbaff 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8598,6 +8598,9 @@ out:
 	return lv;
 
 deactivate_and_revert_new_lv:
+	if (!sync_local_dev_names(lv->vg->cmd))
+		log_error("Failed to sync local devices before reverting %s.",
+			  display_lvname(lv));
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate failed new LV %s. "
 			  "Manual intervention required.",  display_lvname(lv));


