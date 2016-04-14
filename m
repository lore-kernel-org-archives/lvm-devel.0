From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 14 Apr 2016 16:22:14 +0000 (UTC)
Subject: master - toollib: Fix misleading message when forking.
Message-ID: <20160414162214.8015E60B46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c68fb55ac104079e4708d9b869ef8edd9d1202c4
Commit:        c68fb55ac104079e4708d9b869ef8edd9d1202c4
Parent:        3f6e7f90cac72bd248c068f2893ef851d29cf1b9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 14 17:21:02 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 14 17:21:02 2016 +0100

toollib: Fix misleading message when forking.

Commands like pvscan --background run entirely in the background,
but others fork only for polling.
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 2ff5a3b..ce49773 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -54,7 +54,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 		.sa_flags = SA_NOCLDSTOP,
 	};
 
-	log_verbose("Forking background process: %s", cmd->cmd_line);
+	log_verbose("Forking background process from command: %s", cmd->cmd_line);
 
 	sigaction(SIGCHLD, &act, NULL);
 


