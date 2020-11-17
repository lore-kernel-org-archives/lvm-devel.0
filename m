From: David Teigland <teigland@sourceware.org>
Date: Tue, 17 Nov 2020 15:24:32 +0000 (GMT)
Subject: main - lvchange: fix error for foreign vg activation
Message-ID: <20201117152432.9895A3858034@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aba9652e584b6f6a422233dea951eb59326a3de2
Commit:        aba9652e584b6f6a422233dea951eb59326a3de2
Parent:        1cc75317f95def9521af535f4c58fb79df816b8c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 17 09:22:40 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 17 09:22:40 2020 -0600

lvchange: fix error for foreign vg activation

was using ECMD_FAILED instead of 0.
---
 tools/lvchange.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index f9a0b54e3..f37b68381 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -202,7 +202,7 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 	    strcmp(lv->vg->system_id, cmd->system_id) &&
 	    is_change_activating(activate)) {
 		log_error("Cannot activate LVs in a foreign VG.");
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv_activation_skip(lv, activate, arg_is_set(cmd, ignoreactivationskip_ARG)))


