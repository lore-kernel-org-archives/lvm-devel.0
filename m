From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Dec 2022 15:23:37 +0000 (GMT)
Subject: main - pvscan: free unused device_id
Message-ID: <20221220152337.B8CBD3857B8E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=edd6d84159f4d540c8283771da6702971518ccd7
Commit:        edd6d84159f4d540c8283771da6702971518ccd7
Parent:        8f091d379860cf71577629cc1f56191b5f418310
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 20 14:17:34 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 20 15:04:36 2022 +0100

pvscan: free unused device_id

Fix memleak in function.
---
 tools/pvscan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 96935a43b..773862227 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1441,6 +1441,8 @@ static void _warn_excluded_root(struct cmd_context *cmd, struct device *dev)
 
 	log_warn("WARNING: no autoactivation for %s: system.devices %s current %s.",
 		 dev_name(dev), du->idname, cur_idname ?: "missing device id");
+
+	free((void*) cur_idname);
 }
 
 static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,

