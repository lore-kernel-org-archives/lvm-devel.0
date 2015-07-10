From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 10 Jul 2015 20:54:33 +0000 (UTC)
Subject: master - vgexport: do not allow lockd VG to be exported
Message-ID: <20150710205433.C234E60139@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c39f3026a8280bb4c62c785138302cd1475facb6
Commit:        c39f3026a8280bb4c62c785138302cd1475facb6
Parent:        222bb2b88d06a67cc25ed19332919fa339d7e831
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 10 13:49:51 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 10 15:53:21 2015 -0500

vgexport: do not allow lockd VG to be exported

vgexport and vgimport have no use for a shared VG.
---
 tools/vgexport.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/vgexport.c b/tools/vgexport.c
index 6d5b4f6..7e90e5c 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -22,6 +22,13 @@ static int vgexport_single(struct cmd_context *cmd __attribute__((unused)),
 {
 	struct pv_list *pvl;
 
+	/* vgexport/vgimport have to use with shared VGs. */
+	if (is_lockd_type(vg->lock_type)) {
+		log_error("Volume group \"%s\" has lock_type %s that cannot be exported",
+			  vg_name, vg->lock_type);
+		goto bad;
+	}
+
 	if (lvs_in_vg_activated(vg)) {
 		log_error("Volume group \"%s\" has active logical volumes",
 			  vg_name);


