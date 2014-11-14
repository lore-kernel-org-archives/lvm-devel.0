From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 14 Nov 2014 17:17:43 +0000 (UTC)
Subject: master - debug: switch to verbose
Message-ID: <20141114171743.36E6C60DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd32bb1991d8323d655361d19a636e29c6aa62c3
Commit:        fd32bb1991d8323d655361d19a636e29c6aa62c3
Parent:        b6f921e5cb1877263ef5561d6f96141022ff3c6f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 14 16:11:43 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 14 18:12:44 2014 +0100

debug: switch to verbose

When there is no real error from the function - avoid using log_error().
---
 tools/toollib.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index e6573fb..5a17b5d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1569,7 +1569,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
 		/* FIXME Should be log_print, but suppressed for reporting cmds */
-		log_error("No volume groups found");
+		log_verbose("No volume groups found.");
 		return ECMD_PROCESSED;
 	}
 
@@ -1909,7 +1909,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
 		/* FIXME Should be log_print, but suppressed for reporting cmds */
-		log_error("No volume groups found");
+		log_verbose("No volume groups found.");
 		return ECMD_PROCESSED;
 	}
 


