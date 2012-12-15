From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:11 +0000 (UTC)
Subject: master - cleanup: simplify option matching function
Message-ID: <20121215162511.C7B28AAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0396ade38b88431d959ce02fac689306a2c47786
Commit:        0396ade38b88431d959ce02fac689306a2c47786
Parent:        a266154e1fc598ae184780391dc8d8e87eb2c891
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 16:41:24 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 14:57:40 2012 +0100

cleanup: simplify option matching function

Avoid using sprintf and strncmp call, when
we really want to compare just one character.
---
 tools/lvm.c |   17 +++++------------
 1 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/tools/lvm.c b/tools/lvm.c
index 425549a..ec9674e 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -91,18 +91,11 @@ static char *_list_args(const char *text, int state)
 		return NULL;
 
 	/* Short form arguments */
-	if (len < 3) {
-		while (match_no < com->num_args) {
-			char s[3];
-			char c;
-			if (!(c = (_cmdline->arg_props +
-				   com->valid_args[match_no++])->short_arg))
-				continue;
-
-			sprintf(s, "-%c", c);
-			if (!strncmp(text, s, len))
-				return strdup(s);
-		}
+	if (len == 2 && text[0] == '-') {
+		while (match_no < com->num_args)
+			if (text[1] == (_cmdline->arg_props +
+					com->valid_args[match_no++])->short_arg)
+				return strdup(text);
 	}
 
 	/* Long form arguments */


