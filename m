From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  4 Aug 2015 08:26:02 +0000 (UTC)
Subject: master - coverity: variable init must be done before its use
Message-ID: <20150804082602.E4AE0609D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f3d04cddf5a447de9bfb81ed22d0ccbe58e82fc
Commit:        1f3d04cddf5a447de9bfb81ed22d0ccbe58e82fc
Parent:        c78033233ab03749b37c01454310ac0c29fd5af8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 4 09:51:16 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 4 09:51:16 2015 +0200

coverity: variable init must be done before its use

tools/polldaemon.c:465: uninit_use_in_call: Using uninitialized value "id.vg_name" when calling "print_log".
tools/polldaemon.c:465: uninit_use_in_call: Using uninitialized value "id.lv_name" when calling "print_log".
---
 tools/polldaemon.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 4527efb..83928b7 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -461,13 +461,14 @@ static int _lvmpolld_init_poll_vg(struct cmd_context *cmd, const char *vgname,
 		if (!id.display_name && !lpdp->parms->aborting)
 			continue;
 
+		id.vg_name = lv->vg->name;
+		id.lv_name = lv->name;
+
 		if (!*lv->lvid.s) {
 			log_print_unless_silent("Missing LV uuid within: %s/%s", id.vg_name, id.lv_name);
 			continue;
 		}
 
-		id.vg_name = lv->vg->name;
-		id.lv_name = lv->name;
 		id.uuid = lv->lvid.s;
 
 		r = lvmpolld_poll_init(cmd, &id, lpdp->parms);


