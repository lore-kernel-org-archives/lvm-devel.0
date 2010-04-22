From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2010 03:12:03 -0000
Subject: LVM2/old-tests/regex parse_t.c
Message-ID: <20100422031203.25025.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-22 03:12:02

Modified files:
	old-tests/regex: parse_t.c 

Log message:
	add -r to print out closer to original regex format

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/regex/parse_t.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/old-tests/regex/parse_t.c	2010/04/21 08:01:51	1.4
+++ LVM2/old-tests/regex/parse_t.c	2010/04/22 03:12:01	1.5
@@ -67,13 +67,96 @@
 		_pretty_print(rx->right, depth + 1);
 }
 
+static void _regex_print(struct rx_node *rx, int depth)
+{
+	int i, numchars;
+	int left_and_right = (rx->left && rx->right);
+
+	if (left_and_right && rx->type == CAT && rx->left->type == OR)
+		printf("(");
+
+	if (rx->left)
+		_regex_print(rx->left, depth + 1);
+
+	if (left_and_right && rx->type == CAT && rx->left->type == OR)
+		printf(")");
+
+	/* display info about the node */
+	switch (rx->type) {
+	case CAT:
+		//printf("Cat");
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
+	if (left_and_right && rx->type == CAT && rx->right->type == OR)
+		printf("(");
+	if (rx->right)
+		_regex_print(rx->right, depth + 1);
+	if (left_and_right && rx->type == CAT && rx->right->type == OR)
+		printf(")");
+
+	if (!depth)
+		printf("\n");
+}
+
 int main(int argc, char **argv)
 {
 	struct dm_pool *mem;
 	struct rx_node *rx;
+	int regex_print = 0;
+	int regex_arg = 1;
+
+	if (argc == 3 && !strcmp(argv[1], "-r")) {
+		regex_print++;
+		regex_arg++;
+		argc--;
+	}
 
 	if (argc != 2) {
-		fprintf(stderr, "Usage : %s <regex>\n", argv[0]);
+		fprintf(stderr, "Usage : %s [-r] <regex>\n", argv[0]);
 		exit(0);
 	}
 
@@ -84,13 +167,17 @@
 		exit(1);
 	}
 
-	if (!(rx = rx_parse_str(mem, argv[1]))) {
+	if (!(rx = rx_parse_str(mem, argv[regex_arg]))) {
 		dm_pool_destroy(mem);
 		fprintf(stderr, "Couldn't parse regex\n");
 		exit(1);
 	}
 
-	_pretty_print(rx, 0);
+	if (regex_print)
+		_regex_print(rx, 0);
+	else
+		_pretty_print(rx, 0);
+
 	dm_pool_destroy(mem);
 
 	return 0;


