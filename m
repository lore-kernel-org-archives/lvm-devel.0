From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:37 +0000 (GMT)
Subject: stable-2.02 - cov: check strdup for NULL
Message-ID: <20201016191037.F01AA38618E8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b995b8018435ebb51026b57ac536db2d535ec26
Commit:        3b995b8018435ebb51026b57ac536db2d535ec26
Parent:        7e2ceba2fb6ea6769608858f7ce9a88e5ff3eb68
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 15 17:22:18 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:05 2020 +0200

cov: check strdup for NULL

---
 tools/command.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 523753250..2fef6a7a9 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2298,7 +2298,8 @@ static void _print_val_man(struct command_name *cname, int opt_enum, int val_enu
 	}
 
 	if (strchr(str, '|')) {
-		line = dm_strdup(str);
+		if (!(line = dm_strdup(str)))
+			return;
 		_split_line(line, &line_argc, line_argv, '|');
 		for (i = 0; i < line_argc; i++) {
 			if (i)
@@ -3550,9 +3551,12 @@ int main(int argc, char *argv[])
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


