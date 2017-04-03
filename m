From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Apr 2017 17:19:56 -0400
Subject: master - help: include cmd def info in verbose output
Message-ID: <201704032119.v33LJuTf030893@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db579b9e936df14edb9c06830c21e5b5aef666a4
Commit:        db579b9e936df14edb9c06830c21e5b5aef666a4
Parent:        dece723dc72f93cb1ea9c21bd1a6518435832c88
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 3 16:17:37 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 3 16:17:37 2017 -0500

help: include cmd def info in verbose output

It can sometimes be important to correlate a
command with its cmd def entry, so include
the cross reference info in help -vv output.
---
 tools/lvmcmdline.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index bf7e216..bb107d4 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1830,6 +1830,11 @@ static int _usage(const char *name, int longhelp, int skip_notes)
 		if ((_cmdline.commands[i].cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !show_full)
 			continue;
 
+		log_very_verbose("Command definition index %d enum %d id %s",
+			         _cmdline.commands[i].command_index,
+			         _cmdline.commands[i].command_enum,
+			         _cmdline.commands[i].command_id);
+
 		print_usage(&_cmdline.commands[i], show_full, 1);
 		cmd = &_cmdline.commands[i];
 	}


