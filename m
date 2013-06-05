From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:01:00 +0000 (UTC)
Subject: dev-mornfall-lvmcache - Revert "cleanup: simplify option matching function"
Message-ID: <20130605120100.43B5A6140D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9495a3d807b890f7a639e5761b2b37ba495b5d9b
Commit:        9495a3d807b890f7a639e5761b2b37ba495b5d9b
Parent:        c363c74a251a5745e8ac6e274d1f7a1e32fa1843
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Apr 13 02:26:37 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Apr 13 02:26:37 2013 +0100

Revert "cleanup: simplify option matching function"

This reverts commit 0396ade38b88431d959ce02fac689306a2c47786.

The original code also handled len==1, which the new code doesn't.
Press <TAB> in the lvm shell to get a list of the possible
flag completions for a single hyphen.
---
 tools/lvm.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/tools/lvm.c b/tools/lvm.c
index 9b66516..ebce811 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -91,11 +91,18 @@ static char *_list_args(const char *text, int state)
 		return NULL;
 
 	/* Short form arguments */
-	if (len == 2 && text[0] == '-') {
-		while (match_no < com->num_args)
-			if (text[1] == (_cmdline->arg_props +
-					com->valid_args[match_no++])->short_arg)
-				return strdup(text);
+	if (len < 3) {
+		while (match_no < com->num_args) {
+			char s[3];
+			char c;
+			if (!(c = (_cmdline->arg_props +
+				   com->valid_args[match_no++])->short_arg))
+				continue;
+
+			sprintf(s, "-%c", c);
+			if (!strncmp(text, s, len))
+				return strdup(s);
+		}
 	}
 
 	/* Long form arguments */


