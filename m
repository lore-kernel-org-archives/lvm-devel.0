From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 21 Jul 2014 15:01:55 +0000 (UTC)
Subject: master - raid: Correct degraded warning message level
Message-ID: <20140721150155.EFF4160E6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c231a5f4d8e3e309dd018c92644580d06b11dd1
Commit:        8c231a5f4d8e3e309dd018c92644580d06b11dd1
Parent:        27574d0e410c9b78a1bdc14dc6fd3c9ed2b6ca9f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 21 15:40:59 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 21 15:40:59 2014 +0100

raid: Correct degraded warning message level

---
 tools/lvmcmdline.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ccef904..a9769f2 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -982,7 +982,7 @@ static int _get_settings(struct cmd_context *cmd)
 		log_warn("PARTIAL MODE. Incomplete logical volumes will be processed.");
 	} else if (!strcmp(activation_mode, "degraded")) {
 		cmd->degraded_activation = 1;
-		log_debug("DEGRADED MODE. Incomplete RAID LVs will be processed.");
+		log_verbose("DEGRADED MODE. Incomplete RAID LVs will be processed.");
 	} else if (strcmp(activation_mode, "complete")) {
 		log_error("Invalid activation mode given.");
 		return EINVALID_CMD_LINE;


