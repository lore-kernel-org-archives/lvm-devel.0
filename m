From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 20 Mar 2017 12:56:23 -0400
Subject: master - man-generator: Remove unused variable.
Message-ID: <201703201656.v2KGuNO0008065@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3e833c777f46c0c3b3ef70c94cd0fb808be0a50
Commit:        b3e833c777f46c0c3b3ef70c94cd0fb808be0a50
Parent:        862ca6e8b7754b249e989dba934c32170d8074b9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Mar 20 16:55:30 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Mar 20 16:55:30 2017 +0000

man-generator: Remove unused variable.

man-generator.c:2976:6: warning: variable "sep" set but not used
---
 tools/command.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index a344e55..5c0e151 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2973,7 +2973,6 @@ static void _print_man_all_options_list(struct command_name *cname)
 static void _print_man_all_options_desc(struct command_name *cname)
 {
 	int opt_enum, val_enum;
-	int sep = 0;
 	int i;
 
 	for (i = 0; i < ARG_COUNT; i++) {
@@ -3018,8 +3017,6 @@ static void _print_man_all_options_desc(struct command_name *cname)
 		}
 
 		printf(".ad b\n");
-
-		sep = 1;
 	}
 }
 


