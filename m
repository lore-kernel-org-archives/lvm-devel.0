From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 22 Feb 2017 23:01:18 +0000 (UTC)
Subject: master - man: indicate repeatable options
Message-ID: <20170222230118.95BC660574@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da634bfc8933619a70284077b499c82802f04ceb
Commit:        da634bfc8933619a70284077b499c82802f04ceb
Parent:        1eb1869626cbdacbeca037fbd81d01756f2faa76
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 22 16:38:54 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 22 16:38:54 2017 -0600

man: indicate repeatable options

Print ... after a repeatable option in the OPTIONS section.
An alternative would be to just mention in the text description
that the option is repeatable.
---
 tools/command.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index d170eec..1a5fbb5 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -176,8 +176,8 @@ struct opt_name {
 	char _padding[7];
 	const char *long_opt;   /* --foo */
 	int val_enum;           /* xyz_VAL when --foo takes a val like "--foo xyz" */
-	uint32_t unused1;
-	uint32_t unused2;
+	uint32_t flags;
+	uint32_t prio;
 	const char *desc;
 };
 
@@ -2617,7 +2617,6 @@ void print_man_all_options_list(struct command_name *cname)
 
 /*
  * All options used for a given command name, along with descriptions.
- * listed in order of:
  */
 
 void print_man_all_options_desc(struct command_name *cname)
@@ -2656,6 +2655,9 @@ void print_man_all_options_desc(struct command_name *cname)
 			print_val_man(val_names[val_enum].usage);
 		}
 
+		if (opt_names[opt_enum].flags & ARG_COUNTABLE)
+			printf(" ...");
+
 		if (opt_names[opt_enum].desc) {
 			printf("\n");
 			printf(".br\n");


