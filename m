From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 21 Apr 2016 15:32:03 +0000 (UTC)
Subject: master - lvmetad: warn about making changes while not using lvmetad
Message-ID: <20160421153203.CAB81610B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1134ab63240de66850c30fe1576bbb8b4f3e7052
Commit:        1134ab63240de66850c30fe1576bbb8b4f3e7052
Parent:        6e6f8025ff6ad8b3909a4631f71f310821ea7d4b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 21 10:28:01 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 21 10:28:01 2016 -0500

lvmetad: warn about making changes while not using lvmetad

If lvmetad is running, and a command opts to not use it
(--config global/use_lvmetad=0), and the command changes
metadata, then the metadata change is not visible to
lvmetad.  Subsequent commands using lvmetad to change
metadata may cause corruption based on the invalid
lvmetad state.

Eventually we can set the disabled state in lvmetad
to prevent this problem, but for now print a warning
about the possibility.
---
 lib/commands/toolcontext.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 67d4f99..31f3a50 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1720,8 +1720,10 @@ static int _init_lvmetad(struct cmd_context *cmd)
 	}
 
 	if (!find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
-		if (lvmetad_pidfile_present())
+		if (lvmetad_pidfile_present()) {
 			log_warn("WARNING: Not using lvmetad because config setting use_lvmetad=0.");
+			log_warn("WARNING: To avoid corruption, rescan devices to make changes visible (pvscan --cache).");
+		}
 		return 1;
 	}
 


