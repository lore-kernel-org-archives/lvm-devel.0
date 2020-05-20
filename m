From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 May 2020 14:03:19 +0000 (GMT)
Subject: master - cov: check strdup for NULL
Message-ID: <20200520140319.F2DB5395BC64@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce8277b47ed95e71e31c933b5c6a35b24dd52756
Commit:        ce8277b47ed95e71e31c933b5c6a35b24dd52756
Parent:        33fdeaf3f18c02f13fb20e9a7fe8bf99e8e21cba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 15 17:22:18 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 20 15:55:39 2020 +0200

cov: check strdup for NULL

---
 tools/command.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 50791b169..511dda13d 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2319,7 +2319,8 @@ static void _print_val_man(struct command_name *cname, int opt_enum, int val_enu
 	}
 
 	if (strchr(str, '|')) {
-		line = strdup(str);
+		if (!(line = strdup(str)))
+			return;
 		_split_line(line, &line_argc, line_argv, '|');
 		for (i = 0; i < line_argc; i++) {
 			if (i)
@@ -3606,9 +3607,12 @@ int main(int argc, char *argv[])
 		goto out_free;
 	}
 
-	if (optind < argc)
-		cmdname = strdup(argv[optind++]);
-	else {
+	if (optind < argc) {
+		if (!(cmdname = strdup(argv[optind++]))) {
+			log_error("Out of memory.");
+			goto out_free;
+		}
+	} else {
 		log_error("Missing command name.");
 		goto out_free;
 	}


