From: okozina <okozina@fedoraproject.org>
Date: Thu, 16 Apr 2015 15:56:30 +0000 (UTC)
Subject: master - pvmove: fix wrong error path in _update_metadata
Message-ID: <20150416155630.E499160EE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=061e371319676a914a65f07678d0d15f4000c468
Commit:        061e371319676a914a65f07678d0d15f4000c468
Parent:        105c07d1b4d34191ed939f53d98b253e620e449b
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu Apr 16 17:46:38 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Thu Apr 16 17:54:00 2015 +0200

pvmove: fix wrong error path in _update_metadata

fix regression introduced in 65623b63a20a221b48dfd87455dc77f5ac0c6bf4

should return zero no matter the result of resume_lvs fn in error
path
---
 tools/pvmove.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index bef900b..6acac42 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -531,10 +531,9 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 	/* Commit on-disk metadata */
 	if (!vg_commit(vg)) {
 		log_error("ABORTING: First volume group metadata update failed.");
-		if (!resume_lvs(cmd, lvs_changed)) {
+		if (!resume_lvs(cmd, lvs_changed))
 			log_error("Unable to resume logical volumes.");
-			return 0;
-		}
+		return 0;
 	}
 
 	/* Activate the temporary mirror LV */


