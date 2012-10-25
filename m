From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 25 Oct 2012 12:50:02 +0000 (UTC)
Subject: master - lvmetad: whats_new + more explanation for previous commit
Message-ID: <20121025125002.8DF942807@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10492b238d25d85b9aab3eb851bedd1937146e39
Commit:        10492b238d25d85b9aab3eb851bedd1937146e39
Parent:        2fdd0840d5adb1ff492cd09da79f7a2c5290fd2a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 25 14:47:45 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 25 14:47:45 2012 +0200

lvmetad: whats_new + more explanation for previous commit

---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b883bde..4b71402 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Hardcode use_lvmetad=0 if cluster locking used and issue a warning msg.
   Avoid reading mirrors with failed devices in its mirrored log.
   Avoid reading from mirrors that have failed devices if they block I/O.
   Change lvs heading Copy% to Cpy%Sync and print RAID4/5/6 sync% there too.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 1dd23bf..8da96e4 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -416,7 +416,8 @@ static int _process_config(struct cmd_context *cmd)
 	if (find_config_tree_int(cmd, "global/locking_type", 1) != 3)
 		lvmetad_set_active(find_config_tree_int(cmd, "global/use_lvmetad", 0));
 	else {
-		log_warn("WARNING: use_lvmetad overriden to 0 due to locking_type 3");
+		log_warn("WARNING: configuration setting use_lvmetad overriden to 0 due to locking_type 3. "
+			 "Clustered environment not supported by lvmetad yet.");
 		lvmetad_set_active(0);
 	}
 	lvmetad_init(cmd);


