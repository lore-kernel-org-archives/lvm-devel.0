From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 30 Nov 2015 16:58:10 +0000 (UTC)
Subject: master - lvmetad: include both vgid and vgname in lookup request
Message-ID: <20151130165810.12534600F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f357532bb8d6094bffecde48ad8d4b8e4fc430c
Commit:        1f357532bb8d6094bffecde48ad8d4b8e4fc430c
Parent:        cd4d2cff97dc4388080a06cb416861d9139d9d09
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 24 14:47:53 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 30 10:57:30 2015 -0600

lvmetad: include both vgid and vgname in lookup request

When the command already knows both the vgid and vgname,
it should send both to lvmetad for a more exact request,
and it can save lvmetad the work of a name lookup.
---
 lib/cache/lvmetad.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index dced80a..78844c4 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -520,18 +520,29 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 	if (vgid) {
 		if (!id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
 			return_NULL;
-		log_debug_lvmetad("Asking lvmetad for VG %s (%s)", uuid, vgname ? : "name unknown");
+	}
+
+	if (vgid && vgname) {
+		log_debug_lvmetad("Asking lvmetad for VG %s %s", uuid, vgname);
+		reply = _lvmetad_send("vg_lookup",
+				      "uuid = %s", uuid,
+				      "name = %s", vgname,
+				      NULL);
+		diag_name = uuid;
+
+	} else if (vgid) {
+		log_debug_lvmetad("Asking lvmetad for VG vgid %s", uuid);
 		reply = _lvmetad_send("vg_lookup", "uuid = %s", uuid, NULL);
 		diag_name = uuid;
-	} else {
-		if (!vgname) {
-			log_error(INTERNAL_ERROR "VG name required (VGID not available)");
-			reply = _lvmetad_send("vg_lookup", "name = %s", "MISSING", NULL);
-			goto out;
-		}
+
+	} else if (vgname) {
 		log_debug_lvmetad("Asking lvmetad for VG %s", vgname);
 		reply = _lvmetad_send("vg_lookup", "name = %s", vgname, NULL);
 		diag_name = vgname;
+
+	} else {
+		log_error(INTERNAL_ERROR "VG name required (VGID not available)");
+		goto out;
 	}
 
 	if (_lvmetad_handle_reply(reply, "lookup VG", diag_name, &found) && found) {


