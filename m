From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 17 Nov 2015 16:36:24 +0000 (UTC)
Subject: master - lvmetad: improve error message for VGs with same name
Message-ID: <20151117163624.1079C6074C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d37db123d4ea2735c538bf9ad8a57be051ac9c3
Commit:        4d37db123d4ea2735c538bf9ad8a57be051ac9c3
Parent:        485d2ca9454ab4725605ab9a33928164aef1bfc8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 17 09:33:50 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 17 10:35:42 2015 -0600

lvmetad: improve error message for VGs with same name

---
 lib/cache/lvmetad.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index f8393df..8b5bcfb 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -316,6 +316,15 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *action, const c
 		return 1;
 	}
 
+	/* Multiple VGs with the same name were found. */
+	if (found && !strcmp(daemon_reply_str(reply, "response", ""), "multiple")) {
+		log_very_verbose("Request to %s %s%sin lvmetad found multiple matching objects.",
+				 action, object, *object ? " " : "");
+		if (found)
+			*found = 2;
+		return 1;
+	}
+
 	log_error("Request to %s %s%sin lvmetad gave response %s. Reason: %s",
 		  action, object, *object ? " " : "", 
 		  daemon_reply_str(reply, "response", "<missing>"),
@@ -527,6 +536,12 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 
 	if (_lvmetad_handle_reply(reply, "lookup VG", diag_name, &found) && found) {
 
+		if ((found == 2) && vgname) {
+			log_error("Multiple VGs found with the same name: %s.", vgname);
+			log_error("See the --select option with VG UUID (vg_uuid).");
+			goto out;
+		}
+
 		if (!(top = dm_config_find_node(reply.cft->root, "metadata"))) {
 			log_error(INTERNAL_ERROR "metadata config node not found.");
 			goto out;


