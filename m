From: okozina <okozina@fedoraproject.org>
Date: Tue, 28 Apr 2015 21:35:23 +0000 (UTC)
Subject: master - pvmove: make log messages more comprehensible
Message-ID: <20150428213523.2FD76601FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea5c1b0a7310ffb9528a4c3451d347360b021303
Commit:        ea5c1b0a7310ffb9528a4c3451d347360b021303
Parent:        a1474b98f90de0ed272935debc6773f08cdfbace
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu Apr 16 17:40:53 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Apr 28 22:45:54 2015 +0200

pvmove: make log messages more comprehensible

clarify messages printed during pvmove set up (in
_update_metadata fn) and subsequent metadata updates
during a segment progression
---
 tools/pvmove.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 6acac42..90cf5fe 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -516,7 +516,7 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 {
 	int r = 0;
 
-	log_verbose("Updating volume group metadata for the first time.");
+	log_verbose("Setting up pvmove in on-disk volume group metadata.");
 	if (!vg_write(vg)) {
 		log_error("ABORTING: Volume group metadata update failed.");
 		return 0;
@@ -530,7 +530,7 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* Commit on-disk metadata */
 	if (!vg_commit(vg)) {
-		log_error("ABORTING: First volume group metadata update failed.");
+		log_error("ABORTING: Volume group metadata update failed.");
 		if (!resume_lvs(cmd, lvs_changed))
 			log_error("Unable to resume logical volumes.");
 		return 0;


