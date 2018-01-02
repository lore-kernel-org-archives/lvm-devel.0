From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 2 Jan 2018 17:06:27 -0500
Subject: master - toolcontext: Add paired label_init to refresh_toolcontext.
Message-ID: <201801022206.w02M6R9D020172@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b9806ab6f8723630c5284ed2baf1d82c7839a07
Commit:        4b9806ab6f8723630c5284ed2baf1d82c7839a07
Parent:        22b6c482ecb4673c30aa1e9ae1946f9fc5497510
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 2 22:00:31 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 2 22:00:31 2018 +0000

toolcontext: Add paired label_init to refresh_toolcontext.

label_init() and label_exit() should be paired.
---
 lib/commands/toolcontext.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index eda412e..364587c 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -2138,6 +2138,8 @@ int refresh_toolcontext(struct cmd_context *cmd)
 
 	cmd->lib_dir = NULL;
 
+	label_init();
+
 	if (!_init_lvm_conf(cmd))
 		return_0;
 


