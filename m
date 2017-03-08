From: David Teigland <teigland@sourceware.org>
Date: Wed, 8 Mar 2017 16:01:20 -0500
Subject: master - help: fix missing required option
Message-ID: <201703082101.v28L1K5h009077@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4e78b26f53194ef8b3b1e623715c96db1046e42
Commit:        b4e78b26f53194ef8b3b1e623715c96db1046e42
Parent:        4d0172ff15c8af6e5df22afca1c8dc9725c3684f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 8 15:00:27 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 15:00:27 2017 -0600

help: fix missing required option

Fix for previous commit 4d0172ff15c.
---
 tools/command.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index d001f94..1f31468 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1701,9 +1701,6 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		for (ro = 0; ro < cmd->ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
-			if (!opt_names[opt_enum].short_opt)
-				continue;
-
 			if ((opt_enum == size_ARG) && command_has_alternate_extents(cmd->name))
 				include_extents = 1;
 


