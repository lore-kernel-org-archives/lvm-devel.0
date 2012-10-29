From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 29 Oct 2012 15:30:34 +0000 (UTC)
Subject: master - lvmetad: warn only if use_lvmetad=1 and locking_type=3
Message-ID: <20121029153034.89326245D@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c59199d4932d7edcd2919d6d45ec4baac590e2e
Commit:        7c59199d4932d7edcd2919d6d45ec4baac590e2e
Parent:        bbff143d54b890f3b9c91b302f0322469ba56ef6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 29 16:20:35 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 29 16:20:35 2012 +0100

lvmetad: warn only if use_lvmetad=1 and locking_type=3

---
 lib/commands/toolcontext.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 8da96e4..aec4df3 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -413,13 +413,15 @@ static int _process_config(struct cmd_context *cmd)
 	lvmetad_set_socket(lvmetad_socket);
 	cn = find_config_tree_node(cmd, "devices/global_filter");
 	lvmetad_set_token(cn ? cn->v : NULL);
-	if (find_config_tree_int(cmd, "global/locking_type", 1) != 3)
-		lvmetad_set_active(find_config_tree_int(cmd, "global/use_lvmetad", 0));
-	else {
+
+	if (find_config_tree_int(cmd, "global/locking_type", 1) == 3 &&
+	    find_config_tree_int(cmd, "global/use_lvmetad", 0)) {
 		log_warn("WARNING: configuration setting use_lvmetad overriden to 0 due to locking_type 3. "
 			 "Clustered environment not supported by lvmetad yet.");
 		lvmetad_set_active(0);
-	}
+	} else
+		lvmetad_set_active(find_config_tree_int(cmd, "global/use_lvmetad", 0));
+
 	lvmetad_init(cmd);
 
 	return 1;


