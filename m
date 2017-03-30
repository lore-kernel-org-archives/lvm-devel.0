From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 30 Mar 2017 13:56:08 -0400
Subject: master - man-generator: enhance performance
Message-ID: <201703301756.v2UHu899025515@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2c4e8254de59579a84b6c1f3dcc66868b3e9ef34
Commit:        2c4e8254de59579a84b6c1f3dcc66868b3e9ef34
Parent:        0da040b1ebfd4796f9a649f469ebbeb012c7ea1c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 19:55:50 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 19:55:50 2017 +0200

man-generator: enhance performance

Set block buffering on stdout to
save ~30% time generating manuals.
---
 tools/command.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 4c65e6b..7ed63c8 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3418,13 +3418,17 @@ static void _print_man_secondary(char *name)
 	}
 }
 
+#define	STDOUT_BUF_SIZE	 (MAX_MAN_DESC + 4 * 1024)
+
 int main(int argc, char *argv[])
 {
 	char *cmdname = NULL;
 	char *desfile = NULL;
+	char *stdout_buf;
 	int primary = 0;
 	int secondary = 0;
-	int r = 1;
+	int r = 0;
+	size_t sz = STDOUT_BUF_SIZE;
 
 	static struct option long_options[] = {
 		{"primary", no_argument, 0, 'p' },
@@ -3434,6 +3438,11 @@ int main(int argc, char *argv[])
 
 	memset(&commands, 0, sizeof(commands));
 
+	if (!(stdout_buf = dm_malloc(sz)))
+		log_error("Failed to allocate stdout buffer; carrying on with default buffering.");
+	else
+		setbuffer(stdout, stdout_buf, sz);
+
 	while (1) {
 		int c;
 		int option_index = 0;
@@ -3456,14 +3465,14 @@ int main(int argc, char *argv[])
 
 	if (!primary && !secondary) {
 		log_error("Usage: %s --primary|--secondary <command> [/path/to/description-file].", argv[0]);
-		goto out;
+		goto out_free;
 	}
 
 	if (optind < argc)
 		cmdname = strdup(argv[optind++]);
 	else {
 		log_error("Missing command name.");
-		goto out;
+		goto out_free;
 	}
 
 	if (optind < argc)
@@ -3477,10 +3486,15 @@ int main(int argc, char *argv[])
 
 	if (primary)
 		r = _print_man(cmdname, desfile, secondary);
-	else if (secondary)
+	else if (secondary) {
+		r = 1;
 		_print_man_secondary(cmdname);
+	}
+
+out_free:
+	if (stdout_buf)
+		free(stdout_buf);
 
-out:
 	exit(r ? EXIT_SUCCESS: EXIT_FAILURE);
 }
 


