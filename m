From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Apr 2017 16:50:12 -0400
Subject: master - commands: recognize ignored options
Message-ID: <201704032050.v33KoCqI026560@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dece723dc72f93cb1ea9c21bd1a6518435832c88
Commit:        dece723dc72f93cb1ea9c21bd1a6518435832c88
Parent:        162272e5a5ad5249c30f024c9dc69f5a1ece8fea
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 3 15:24:46 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 3 15:49:24 2017 -0500

commands: recognize ignored options

---
 tools/lvmcmdline.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6f70481..bf7e216 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1154,7 +1154,7 @@ static void _set_valid_args_for_command_name(int ci)
 	int num_args = 0;
 	int opt_enum; /* foo_ARG from args.h */
 	int opt_syn;
-	int i, ro, oo;
+	int i, ro, oo, io;
 
 	/*
 	 * all_args is indexed by the foo_ARG enum vals
@@ -1173,6 +1173,10 @@ static void _set_valid_args_for_command_name(int ci)
 			opt_enum = commands[i].optional_opt_args[oo].opt;
 			all_args[opt_enum] = 1;
 		}
+		for (io = 0; io < commands[i].io_count; io++) {
+			opt_enum = commands[i].ignore_opt_args[io].opt;
+			all_args[opt_enum] = 1;
+		}
 	}
 
 	for (i = 0; i < ARG_COUNT; i++) {


