From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:35 +0000 (UTC)
Subject: master - pvmove.c: relocate id components extraction
Message-ID: <20150515183735.B3068613FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04c77bd8863b071b9e376c76708af6cede596a45
Commit:        04c77bd8863b071b9e376c76708af6cede596a45
Parent:        67657f1ff938b2afd17ab0ce6476a561725a6781
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 15 17:06:14 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:33:21 2015 +0200

pvmove.c: relocate id components extraction

we don't want to fail properly set pvmove after metadata
update. failure to copy id components could end with dangling
mirror moving PV segments but no monitoring from lvmpolld or
classical polldaemon.
---
 tools/pvmove.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 202c87c..94a5ffc 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -686,13 +686,13 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	/* init_pvmove(1); */
 	/* vg->status |= PVMOVE; */
 
+	if (!_copy_id_components(cmd, lv_mirr, vg_name, lv_mirr_name, lvid))
+		goto out;
+
 	if (flags & PVMOVE_FIRST_TIME)
 		if (!_update_metadata(cmd, vg, lv_mirr, lvs_changed, exclusive))
 			goto_out;
 
-	if (!_copy_id_components(cmd, lv_mirr, vg_name, lv_mirr_name, lvid))
-		goto out;
-
 	/* LVs are all in status LOCKED */
 	r = ECMD_PROCESSED;
 out:


