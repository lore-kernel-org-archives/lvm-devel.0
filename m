From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 16 Jan 2013 10:21:24 +0000 (UTC)
Subject: master - lvmetad: Call _lvmetad_handle_reply in lvmetad_vg_lookup.
Message-ID: <20130116102124.C2CC9AAC68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e4a9534f4c0a04300f07bdbcfb62ba18bc82523
Commit:        1e4a9534f4c0a04300f07bdbcfb62ba18bc82523
Parent:        15fdd5c90dda7f00f691668c13d5401206d22021
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jan 16 11:12:22 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jan 16 11:19:33 2013 +0100

lvmetad: Call _lvmetad_handle_reply in lvmetad_vg_lookup.

---
 lib/cache/lvmetad.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 9b54174..e7f00ac 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -306,11 +306,12 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 {
 	struct volume_group *vg = NULL;
 	daemon_reply reply;
+	int found;
 	char uuid[64];
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
 	struct dm_config_node *top;
-	const char *name;
+	const char *name, *diag_name;
 	const char *fmt_name;
 	struct format_type *fmt;
 	struct dm_config_node *pvcn;
@@ -325,14 +326,16 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 			return_NULL;
 		log_debug_lvmetad("Asking lvmetad for VG %s (%s)", uuid, vgname ? : "name unknown");
 		reply = _lvmetad_send("vg_lookup", "uuid = %s", uuid, NULL);
+		diag_name = uuid;
 	} else {
 		if (!vgname)
 			log_error(INTERNAL_ERROR "VG name required (VGID not available)");
 		log_debug_lvmetad("Asking lvmetad for VG %s", vgname);
 		reply = _lvmetad_send("vg_lookup", "name = %s", vgname, NULL);
+		diag_name = vgname;
 	}
 
-	if (!reply.error && !strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+	if (_lvmetad_handle_reply(reply, "lookup VG", diag_name, &found) && found) {
 
 		if (!(top = dm_config_find_node(reply.cft->root, "metadata"))) {
 			log_error(INTERNAL_ERROR "metadata config node not found.");


