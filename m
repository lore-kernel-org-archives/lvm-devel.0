From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 25 Feb 2015 14:17:01 +0000 (UTC)
Subject: master - systemid: Improve concurrent warning.
Message-ID: <20150225141701.190B1601E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=809a5e142eec520aab2702fd3b8cfafc1d16ffac
Commit:        809a5e142eec520aab2702fd3b8cfafc1d16ffac
Parent:        ac6a4cd7079fa97f866cde5ba3adedbf7fd61cba
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Feb 25 14:17:35 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Feb 25 14:17:35 2015 +0000

systemid: Improve concurrent warning.

---
 tools/toollib.c  |    2 +-
 tools/vgchange.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 628bc55..8b750d8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -775,7 +775,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 				log_warn("VG with system ID \"%s\" might become inaccessible as local system ID is \"%s\"",
 					 vp_new->system_id, cmd->system_id);
 			else
-				log_warn("WARNING: A VG without a system ID allows concurrent access from other hosts.");
+				log_warn("WARNING: A VG without a system ID allows unsafe access from other hosts.");
 		}
 	}
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 8d5b48a..c03d814 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -506,7 +506,7 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 
 	if (cmd->system_id && strcmp(system_id, cmd->system_id)) {
 		if (!*system_id) {
-			log_warn("WARNING: Removing the system ID allows concurrent access from other hosts.");
+			log_warn("WARNING: Removing the system ID allows unsafe access from other hosts.");
 
 			if (!arg_count(cmd, yes_ARG) &&
 			    yes_no_prompt("Remove system ID %s on volume group %s? [y/n]: ",


