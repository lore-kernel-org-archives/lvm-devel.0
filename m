From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 May 2019 17:54:42 -0400
Subject: master - pvscan: fix segfault in recent commit
Message-ID: <201905032154.x43LsgIt000331@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9f561f2206bd893ea5ef7052debaff2af97006d1
Commit:        9f561f2206bd893ea5ef7052debaff2af97006d1
Parent:        3405ead1e09aa6916cd5ac84ae629c13991e6ec5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 3 16:51:34 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 3 16:51:34 2019 -0500

pvscan: fix segfault in recent commit

commit aa75b31db5478
  "pvscan: handle case of scanning PV without metadata last"

failed to recognize that an arg may be null in the case of
'pvscan --cache' (without -aay) which does not keep track
of complete VGs because it does not need to activate them.
---
 tools/pvscan.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index e389106..6d89426 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -759,6 +759,10 @@ static void _check_vg_with_pvid_complete(struct cmd_context *cmd,
  *
  * . When dev_args is set, then complete VGs that that contain
  *   devs in dev_args will be returned in found_vgnames.
+ *
+ * found_vgnames is null for 'pvscan --cache' (without -aay)
+ * since the command does not need to keep track of complete
+ * vgs since it does not need to activate them.
  */
 
 static void _online_pvscan_all_devs(struct cmd_context *cmd,
@@ -794,7 +798,7 @@ static void _online_pvscan_all_devs(struct cmd_context *cmd,
 		}
 
 		/* This PV without metadata may complete a VG. */
-		if (pvid_without_metadata)
+		if (pvid_without_metadata && found_vgnames)
 			_check_vg_with_pvid_complete(cmd, found_vgnames, &all_vgs, pvid_without_metadata);
 	}
 


