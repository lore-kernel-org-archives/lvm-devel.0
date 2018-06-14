From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:03:04 -0400
Subject: master - vgchange: trace faling activation
Message-ID: <201806142003.w5EK34aV003588@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=33703995ae264c7abdc6d566283d94d8587a85f1
Commit:        33703995ae264c7abdc6d566283d94d8587a85f1
Parent:        f38a54227d71b6fd661d83609f46459306bc373a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 21:04:53 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

vgchange: trace faling activation

Trace failed activation and directly assign 0 returning failure.
---
 tools/vgchange.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 71a6c54..55bc476 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -116,8 +116,11 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		expected_count++;
 
-		if (!lv_change_activate(cmd, lv, activate))
+		if (!lv_change_activate(cmd, lv, activate)) {
+			stack;
+			r = 0;
 			continue;
+		}
 
 		count++;
 	}
@@ -135,7 +138,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			    is_change_activating(activate) ?
 			    "Activated" : "Deactivated", count, vg->name);
 
-	return (expected_count != count) ? 0 : r;
+	return r;
 }
 
 static int _vgchange_monitoring(struct cmd_context *cmd, struct volume_group *vg)


