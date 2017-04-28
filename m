From: David Teigland <teigland@sourceware.org>
Date: Fri, 28 Apr 2017 17:51:20 -0400
Subject: master - fix running commands from a script file
Message-ID: <201704282151.v3SLpKmV027145@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=54726a4950756b8f0c3e19c4c7d5feb6fb838e00
Commit:        54726a4950756b8f0c3e19c4c7d5feb6fb838e00
Parent:        c73b9f062c8ed59dc0bfa859cab4a692295a56cb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 28 16:43:42 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 28 16:51:04 2017 -0500

fix running commands from a script file

Using any arg with a command name in a script file
would cause the command to fail.

The name of the script file being executed was being passed
to lvm_register_commands() and define_commands(), which
prevented command defs from being defined (simple commands
were still being defined only by name which was enough for those
to still work when run trivially with no args).
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2db7dc4..846e998 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.171 - 
 ==================================
+  Fix running commands from a script file.
   Add pvcreate prompt when device size doesn't match setphysicalvolumesize.
   lvconvert - preserve region size on raid1 image count changes
   Adjust pvresize/pvcreate messages and prompt if underlying dev size differs.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c0c81ba..29ec06b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3444,6 +3444,10 @@ int lvm2_main(int argc, char **argv)
 		goto_out;
 	}
 
+	/* Can be the name of a script file. */
+	if (run_name && !find_command_name(run_name))
+		run_name = NULL;
+
 	if (!lvm_register_commands(run_name)) {
 		ret = ECMD_FAILED;
 		goto out;


