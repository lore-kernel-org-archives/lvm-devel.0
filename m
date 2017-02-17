From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 17 Feb 2017 12:25:36 +0000 (UTC)
Subject: master - commands: optimize binary search
Message-ID: <20170217122536.53CD260E97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=772834e40aef44a8f7bc884050e1b88087073706
Commit:        772834e40aef44a8f7bc884050e1b88087073706
Parent:        582a272b3f401e1bb6eafaa52d0ed1d318d04a9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 17 10:00:43 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 13:20:55 2017 +0100

commands: optimize binary search

Since there is a lot of options and lot of searches,
use binary search to keep strcmp at minimum.

The interesting part is - alphabetically sorted array contains
duplicates and some of them are not the 'right anwer', so
after we find matching string but not matching long_ARG,
we may need to check if the surrouding strings are the right matching
one.

The single loops is used also for strictly define --foo_long
(i.e. --stripes)  and just differs at final part.

TODO1: replace strstr call with some flag (just like short_opt).
TODO2: drop '--' from being stored and tests by strcmp.
---
 tools/command.c |   79 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 45 insertions(+), 34 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index e5a4640..b202878 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -359,46 +359,57 @@ static int opt_str_to_num(struct command *cmd, char *str)
 	char long_name[MAX_LONG_OPT_NAME_LEN];
 	char *p;
 	int i;
+	int first = 0, last = ARG_COUNT - 1, middle;
 
-	/*
-	 * --foo_long means there are two args entries
-	 * for --foo, one with a short option and one
-	 * without, and we want the one without the
-	 * short option.
-	 */
-	if (strstr(str, "_long")) {
-		memset(long_name, 0, sizeof(long_name));
-		strncpy(long_name, str, MAX_LONG_OPT_NAME_LEN-1);
-		if ((p = strstr(long_name, "_long")))
-			*p = '\0';
-
-		for (i = 0; i < ARG_COUNT; i++) {
-			if (!opt_names[i].long_opt)
-				continue;
-			/* skip anything with a short opt */
-			if (opt_names[i].short_opt)
-				continue;
-			if (!strcmp(opt_names[i].long_opt, long_name))
-				return opt_names[i].opt_enum;
-		}
+	dm_strncpy(long_name, str, sizeof(long_name));
 
-		log_error("Parsing command defs: unknown opt str: %s %s", str, long_name);
-		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
-		return ARG_UNUSED;
-	}
+	if ((p = strstr(long_name, "_long")))
+		/*
+		 * --foo_long means there are two args entries
+		 * for --foo, one with a short option and one
+		 * without, and we want the one without the
+		 * short option (== 0).
+		 */
+		*p = '\0';
 
-	for (i = 0; i < ARG_COUNT; i++) {
-		if (!opt_names[i].long_opt)
-			continue;
-		/* These are only selected using --foo_long */
-		if (strstr(opt_names[i].name, "_long_ARG"))
-			continue;
-		if (!strcmp(opt_names[i].long_opt, str))
-			return opt_names[i].opt_enum;
+	/* Binary search in sorted array of long options (with duplicates) */
+	while (first <= last) {
+		middle = first + (last - first) / 2;
+		if ((i = strcmp(opt_names_alpha[middle]->long_opt, long_name)) < 0)
+			first = middle + 1;
+		else if (i > 0)
+			last = middle - 1;
+		else {
+			/* Matching long option string found.
+			 * As sorted array contains duplicates, we need to also
+			 * check left & right side for possible match
+			 */
+			for (i = middle;;) {
+				if ((!p && !strstr(opt_names_alpha[i]->name, "_long_ARG")) ||
+				    (p && !opt_names_alpha[i]->short_opt))
+					return opt_names_alpha[i]->opt_enum; /* Found */
+				/* Check if there is something on the 'left-side' */
+				if ((i <= first) || strcmp(opt_names_alpha[--i]->long_opt, long_name))
+					break;
+			}
+
+			/* Nothing on the left, so look on the 'right-side' */
+			for (i = middle + 1; i <= last; ++i) {
+				if (strcmp(opt_names_alpha[i]->long_opt, long_name))
+					break;
+				if ((!p && !strstr(opt_names_alpha[i]->name, "_long_ARG")) ||
+				    (p && !opt_names_alpha[i]->short_opt))
+					return opt_names_alpha[i]->opt_enum; /* Found */
+			}
+
+			break; /* Nothing... */
+		}
 	}
 
-	log_error("Parsing command defs: unknown opt str: \"%s\"", str);
+	log_error("Parsing command defs: unknown opt str: \"%s\"%s%s.",
+		  str, p ? " ": "", p ? long_name : "");
 	cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+
 	return ARG_UNUSED;
 }
 


