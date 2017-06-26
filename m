From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 18:29:40 -0400
Subject: master - debug: tracing error path
Message-ID: <201706262229.v5QMTeIp010194@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c3e0ef1a5eef973bb79c3f94653077cc87b250c0
Commit:        c3e0ef1a5eef973bb79c3f94653077cc87b250c0
Parent:        c440bb0742fa70ca37ead55b7edd18e2f7a19eda
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 26 23:21:22 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 00:27:36 2017 +0200

debug: tracing error path

---
 tools/lvm.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/lvm.c b/tools/lvm.c
index 0554007..4bfa6f5 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -335,7 +335,8 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 	free(input);
 
 	if (cmd->cmd_report.report_group) {
-		dm_report_group_destroy(cmd->cmd_report.report_group);
+		if (!dm_report_group_destroy(cmd->cmd_report.report_group))
+			stack;
 		cmd->cmd_report.report_group = NULL;
 	}
 


