From: David Teigland <teigland@sourceware.org>
Date: Fri, 10 Mar 2017 12:50:49 -0500
Subject: master - commands: fix missing skip condition in coverity fixes
Message-ID: <201703101750.v2AHoniW023399@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43388f12208be07191b80a5ed328a87790ecd64a
Commit:        43388f12208be07191b80a5ed328a87790ecd64a
Parent:        a9341b18ef6cb20245a74fc97aa28dd7283804f3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 10 11:49:24 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 10 11:50:00 2017 -0600

commands: fix missing skip condition in coverity fixes

Fix for commit 5e6ea4b7
---
 tools/command.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index aacc647..9594284 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1506,7 +1506,8 @@ int define_commands(char *run_name)
 			continue;
 		}
 
-		log_error("Parsing command defs: can't process input line %s", line_orig);
+		if (!skip)
+			log_error("Parsing command defs: can't process input line %s", line_orig);
 	}
 
 	for (i = 0; i < COMMAND_COUNT; i++) {


