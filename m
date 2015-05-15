From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:33 +0000 (UTC)
Subject: master - lvpoll.c: harden the checks for proper LV name
Message-ID: <20150515183733.A350F60E34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67657f1ff938b2afd17ab0ce6476a561725a6781
Commit:        67657f1ff938b2afd17ab0ce6476a561725a6781
Parent:        ba120640b2db0acf166d60046cd3b0afdf7774b0
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 15 16:35:00 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:33:10 2015 +0200

lvpoll.c: harden the checks for proper LV name

lvpoll now process passed LV name properly. It respects
LVM_VG_NAME env. variable and is able to process LV name
passed in various formats:

- VG/LV
- LV name only (with LVM_VG_NAME set)
- /dev/mapper/VG-LV
- /dev/VG/LV
---
 tools/lvpoll.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/tools/lvpoll.c b/tools/lvpoll.c
index 945e5d1..0ed2d45 100644
--- a/tools/lvpoll.c
+++ b/tools/lvpoll.c
@@ -83,11 +83,17 @@ static int poll_lv(struct cmd_context *cmd, const char *lv_name)
 {
 	struct daemon_parms parms = { 0 };
 	struct poll_operation_id id = {
-		.vg_name = extract_vgname(cmd, lv_name),
-		.lv_name = strchr(lv_name, '/') + 1,
-		.display_name = lv_name
+		.display_name = skip_dev_dir(cmd, lv_name, NULL)
 	};
 
+	if (!id.display_name)
+		return_EINVALID_CMD_LINE;
+
+	id.lv_name = id.display_name;
+
+	if (!validate_lvname_param(cmd, &id.vg_name, &id.lv_name))
+		return_EINVALID_CMD_LINE;
+
 	if (!_set_daemon_parms(cmd, &parms))
 		return_EINVALID_CMD_LINE;
 
@@ -106,8 +112,8 @@ int lvpoll(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!argc || !strchr(argv[0], '/')) {
-		log_error("Provide full VG/LV name");
+	if (!argc) {
+		log_error("Provide LV name");
 		return EINVALID_CMD_LINE;
 	}
 


