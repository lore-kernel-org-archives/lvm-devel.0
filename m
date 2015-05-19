From: okozina <okozina@fedoraproject.org>
Date: Tue, 19 May 2015 19:02:55 +0000 (UTC)
Subject: master - polldaemon.c: call vg_read directly
Message-ID: <20150519190255.892FF60FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d300b70f911beacf099daa3950e1e77c30f27c2
Commit:        0d300b70f911beacf099daa3950e1e77c30f27c2
Parent:        15939e34353cc4bb89e674eac5b51a32fbd094e9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 19 14:40:40 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 19 20:55:50 2015 +0200

polldaemon.c: call vg_read directly

replace calls in wait_for_single_lv() and report_progress() fns
---
 tools/polldaemon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 7f25887..2cb56fa 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -171,7 +171,7 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 			_sleep_and_rescan_devices(parms);
 
 		/* Locks the (possibly renamed) VG again */
-		vg = parms->poll_fns->get_copy_vg(cmd, id->vg_name, NULL, READ_FOR_UPDATE);
+		vg = vg_read(cmd, id->vg_name, NULL, READ_FOR_UPDATE);
 		if (vg_read_error(vg)) {
 			release_vg(vg);
 			log_error("ABORTING: Can't reread VG for %s.", id->display_name);
@@ -379,7 +379,7 @@ static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id
 	struct volume_group *vg;
 	struct logical_volume *lv;
 
-	vg = parms->poll_fns->get_copy_vg(cmd, id->vg_name, NULL, 0);
+	vg = vg_read(cmd, id->vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		log_error("Can't reread VG for %s", id->display_name);


