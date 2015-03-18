From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 18 Mar 2015 23:58:14 +0000 (UTC)
Subject: master - systemid: Use correct mempool.
Message-ID: <20150318235814.ADE666100F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87941ccd1706ac9818f0f4828cade1d4cfae622d
Commit:        87941ccd1706ac9818f0f4828cade1d4cfae622d
Parent:        80f4b4b8039a88dfa2648a9b5bb5e16f41b81f87
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 18 23:25:30 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 18 23:25:30 2015 +0000

systemid: Use correct mempool.

libmem is necessary when this ends up in cmd->system_id.
---
 lib/commands/toolcontext.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 54dcf86..fb0e94d 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -67,7 +67,7 @@ const char *system_id_from_string(struct cmd_context *cmd, const char *str)
 		return "";
 	}
 
-	if (!(system_id = dm_pool_zalloc(cmd->mem, strlen(str) + 1))) {
+	if (!(system_id = dm_pool_zalloc(cmd->libmem, strlen(str) + 1))) {
 		log_warn("WARNING: Failed to allocate system ID.");
 		return NULL;
 	}


