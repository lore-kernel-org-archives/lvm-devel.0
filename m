From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Apr 2017 17:42:43 -0400
Subject: master - help: print all options in abbreviated help output
Message-ID: <201704032142.v33LghZ6001094@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b951d0433765d3ed7b0507906dec1894053cef4f
Commit:        b951d0433765d3ed7b0507906dec1894053cef4f
Parent:        29161a145e9c1c50157dca30c17957e4699826d6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 3 16:36:04 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 3 16:36:04 2017 -0500

help: print all options in abbreviated help output

Don't abbreviate the --help output quite as much
when there are many command defs.  Print all the
options in the cmd defs that are shown.  --longhelp
output is unchanged and includes everything.
---
 tools/lvmcmdline.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index bb107d4..280a052 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1835,15 +1835,13 @@ static int _usage(const char *name, int longhelp, int skip_notes)
 			         _cmdline.commands[i].command_enum,
 			         _cmdline.commands[i].command_id);
 
-		print_usage(&_cmdline.commands[i], show_full, 1);
+		print_usage(&_cmdline.commands[i], 1, 1);
 		cmd = &_cmdline.commands[i];
 	}
 
 	/* Common options are printed once for all variants of a command name. */
-	if (show_full) {
-		print_usage_common_cmd(cname, cmd);
-		print_usage_common_lvm(cname, cmd);
-	}
+	print_usage_common_cmd(cname, cmd);
+	print_usage_common_lvm(cname, cmd);
 
 	if (skip_notes)
 		return 1;


