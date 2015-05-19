From: okozina <okozina@fedoraproject.org>
Date: Tue, 19 May 2015 19:03:08 +0000 (UTC)
Subject: master - polldaemon.c: do not report error when LV not found
Message-ID: <20150519190308.4705360FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6b5eb88f23701446653ed616b54bec15c54d42d
Commit:        e6b5eb88f23701446653ed616b54bec15c54d42d
Parent:        cf5b4a228612981ec5de358adad670014e885e4c
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 19 17:04:29 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 19 20:56:46 2015 +0200

polldaemon.c: do not report error when LV not found

currently in wait_for_single_lv() fn trying to poll missing pvmove LV
is considered success. It may have been already finished by another
instance of polldaemon. either by another forked off polldaemon
or by lvmpolld.

Let's try to handle the mirror conversion and snapshot merge the same
way.
---
 tools/polldaemon.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 9f4fc94..fe2e7fd 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -160,18 +160,16 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		if (lv && parms->lv_type && !(lv->status & parms->lv_type))
 			lv = NULL;
 
-		if (!lv && parms->lv_type == PVMOVE) {
-			log_print_unless_silent("%s: No pvmove in progress - already finished or aborted.",
-						id->display_name);
-			unlock_and_release_vg(cmd, vg, vg->name);
-			return 1;
-		}
-
 		if (!lv) {
-			log_error("ABORTING: Can't find LV in %s for %s.",
-				  vg->name, id->display_name);
+			if (parms->lv_type == PVMOVE)
+				log_print_unless_silent("%s: No pvmove in progress - already finished or aborted.",
+							id->display_name);
+			else
+				log_print_unless_silent("Can't find LV in %s for %s.",
+							vg->name, id->display_name);
+
 			unlock_and_release_vg(cmd, vg, vg->name);
-			return 0;
+			return 1;
 		}
 
 		/*


