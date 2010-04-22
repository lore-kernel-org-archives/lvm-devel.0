From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2010 17:42:39 -0000
Subject: LVM2 libdm/regex/parse_rx.c old-tests/regex/pa ...
Message-ID: <20100422174239.28460.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-22 17:42:38

Modified files:
	libdm/regex    : parse_rx.c 
	old-tests/regex: parse_t.c 

Log message:
	Move regex printing code from test to main tree (may use in debug messages).
	Yet another optimiser fix attempt.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/regex/parse_t.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/libdm/regex/parse_rx.c	2010/04/22 14:33:14	1.8
+++ LVM2/libdm/regex/parse_rx.c	2010/04/22 17:42:38	1.9
@@ -16,6 +16,85 @@
 #include "dmlib.h"
 #include "parse_rx.h"
 
+#ifdef DEBUG
+#include <ctype.h>
+
+static void _regex_print(struct rx_node *rx, int depth, unsigned show_nodes)
+{
+	int i, numchars;
+
+	if (rx->left) {
+		if (rx->left->type != CHARSET && (show_nodes || (!((rx->type == CAT || rx->type == OR) && rx->left->type == CAT))))
+			printf("(");
+
+		_regex_print(rx->left, depth + 1, show_nodes);
+
+		if (rx->left->type != CHARSET && (show_nodes || (!((rx->type == CAT || rx->type == OR) && rx->left->type == CAT))))
+			printf(")");
+	}
+
+	/* display info about the node */
+	switch (rx->type) {
+	case CAT:
+		break;
+
+	case OR:
+		printf("|");
+		break;
+
+	case STAR:
+		printf("*");
+		break;
+
+	case PLUS:
+		printf("+");
+		break;
+
+	case QUEST:
+		printf("?");
+		break;
+
+	case CHARSET:
+		numchars = 0;
+		for (i = 0; i < 256; i++)
+			if (dm_bit(rx->charset, i) && (isprint(i) || i == HAT_CHAR || i == DOLLAR_CHAR))
+				numchars++;
+		if (numchars == 97) {
+			printf(".");
+			break;
+		}
+		if (numchars > 1)
+			printf("[");
+		for (i = 0; i < 256; i++)
+			if (dm_bit(rx->charset, i)) {
+				if isprint(i)
+					printf("%c", (char) i);
+				else if (i == HAT_CHAR)
+					printf("^");
+				else if (i == DOLLAR_CHAR)
+					printf("$");
+			}
+		if (numchars > 1)
+			printf("]");
+		break;
+
+	default:
+		fprintf(stderr, "Unknown type");
+	}
+
+	if (rx->right) {
+		if (rx->right->type != CHARSET && (show_nodes || (!(rx->type == CAT && rx->right->type == CAT) && rx->right->right)))
+			printf("(");
+		_regex_print(rx->right, depth + 1, show_nodes);
+		if (rx->right->type != CHARSET && (show_nodes || (!(rx->type == CAT && rx->right->type == CAT) && rx->right->right)))
+			printf(")");
+	}
+
+	if (!depth)
+		printf("\n");
+}
+#endif /* DEBUG */
+
 struct parse_sp {		/* scratch pad for the parsing process */
 	struct dm_pool *mem;
 	int type;		/* token type, 0 indicates a charset */
@@ -342,10 +421,16 @@
 static unsigned _depth(struct rx_node *r, unsigned leftmost)
 {
 	int count = 1;
+	int or_count = 0;
 
 	while (r->type != CHARSET && LEFT(r)) {
 		count++;
 		r = LEFT(r);
+		/* Stop if we pass another OR */
+		if (or_count)
+			break;
+		if (r->type == OR)
+			or_count++;
 	}
 
 	return count;
--- LVM2/old-tests/regex/parse_t.c	2010/04/22 03:42:00	1.6
+++ LVM2/old-tests/regex/parse_t.c	2010/04/22 17:42:38	1.7
@@ -14,6 +14,7 @@
  */
 
 /* hack - using unexported internal function */
+#define DEBUG
 #include "regex/parse_rx.c"
 
 #include <stdio.h>
@@ -67,86 +68,12 @@
 		_pretty_print(rx->right, depth + 1);
 }
 
-static void _regex_print(struct rx_node *rx, int depth)
-{
-	int i, numchars;
-	int left_and_right = (rx->left && rx->right);
-
-	if (left_and_right && rx->type == CAT && rx->left->type == OR)
-		printf("(");
-
-	if (rx->left)
-		_regex_print(rx->left, depth + 1);
-
-	if (left_and_right && rx->type == CAT && rx->left->type == OR)
-		printf(")");
-
-	/* display info about the node */
-	switch (rx->type) {
-	case CAT:
-		//printf("Cat");
-		break;
-
-	case OR:
-		printf("|");
-		break;
-
-	case STAR:
-		printf("*");
-		break;
-
-	case PLUS:
-		printf("+");
-		break;
-
-	case QUEST:
-		printf("?");
-		break;
-
-	case CHARSET:
-		numchars = 0;
-		for (i = 0; i < 256; i++)
-			if (dm_bit(rx->charset, i) && (isprint(i) || i == HAT_CHAR || i == DOLLAR_CHAR))
-				numchars++;
-		if (numchars == 97) {
-			printf(".");
-			break;
-		}
-		if (numchars > 1)
-			printf("[");
-		for (i = 0; i < 256; i++)
-			if (dm_bit(rx->charset, i)) {
-				if (isprint(i))
-					printf("%c", (char) i);
-				else if (i == HAT_CHAR)
-					printf("^");
-				else if (i == DOLLAR_CHAR)
-					printf("$");
-			}
-		if (numchars > 1)
-			printf("]");
-		break;
-
-	default:
-		fprintf(stderr, "Unknown type");
-	}
-
-	if (left_and_right && rx->type == CAT && rx->right->type == OR)
-		printf("(");
-	if (rx->right)
-		_regex_print(rx->right, depth + 1);
-	if (left_and_right && rx->type == CAT && rx->right->type == OR)
-		printf(")");
-
-	if (!depth)
-		printf("\n");
-}
-
 int main(int argc, char **argv)
 {
 	struct dm_pool *mem;
 	struct rx_node *rx;
 	int regex_print = 0;
+	int show_nodes = 0;
 	int regex_arg = 1;
 
 	if (argc == 3 && !strcmp(argv[1], "-r")) {
@@ -155,6 +82,13 @@
 		argc--;
 	}
 
+	if (argc == 3 && !strcmp(argv[1], "-R")) {
+		regex_print++;
+		show_nodes++;
+		regex_arg++;
+		argc--;
+	}
+
 	if (argc != 2) {
 		fprintf(stderr, "Usage : %s [-r] <regex>\n", argv[0]);
 		exit(0);
@@ -174,7 +108,7 @@
 	}
 
 	if (regex_print)
-		_regex_print(rx, 0);
+		_regex_print(rx, 0, show_nodes);
 	else
 		_pretty_print(rx, 0);
 


