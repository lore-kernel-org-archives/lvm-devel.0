From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  8 Jul 2015 13:10:36 +0000 (UTC)
Subject: master - coverity: fix NULL check in lv->lvid.s
Message-ID: <20150708131036.2C21C60F02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b48233f2548621c42129b8f0e2911e05c206660
Commit:        6b48233f2548621c42129b8f0e2911e05c206660
Parent:        3ec4813ba22adedb8914089b6f17fe779d76ee77
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 8 15:08:39 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 8 15:08:39 2015 +0200

coverity: fix NULL check in lv->lvid.s

tools/polldaemon.c:457: array_null: Comparing an array to null is not useful: "lv->lvid.s"

The lv->lvid.s is never NULL. The check was supposed to be *lv->lvid.s
to check if the string is not empty.
---
 tools/polldaemon.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index ab9e474..bbe4641 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -454,7 +454,7 @@ static int _lvmpolld_init_poll_vg(struct cmd_context *cmd, const char *vgname,
 		if (!id.display_name && !lpdp->parms->aborting)
 			continue;
 
-		if (!lv->lvid.s) {
+		if (!*lv->lvid.s) {
 			log_print_unless_silent("Missing LV uuid within: %s/%s", id.vg_name, id.lv_name);
 			continue;
 		}


