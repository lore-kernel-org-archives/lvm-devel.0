From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 17 Apr 2007 13:24:43 -0400
Subject: [PATCH 2/2] add lib/config support functions
Message-ID: <1176830683.4070.21.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add support functions for analysis of config sections,
and hence, on-disk LVM2 metadata.
Should not change functional behavior.

Index: LVM2/lib/config/config.c
===================================================================
--- LVM2.orig/lib/config/config.c	2007-04-17 13:11:08.000000000 -0400
+++ LVM2/lib/config/config.c	2007-04-17 13:16:25.000000000 -0400
@@ -26,6 +26,9 @@
 #include <fcntl.h>
 #include <ctype.h>
 
+#define TOK_SECTION_B_CHAR '{'
+#define TOK_SECTION_E_CHAR '}'
+
 enum {
 	TOK_INT,
 	TOK_FLOAT,
@@ -474,7 +477,7 @@ static struct config_node *_file(struct 
 
 static struct config_node *_section(struct parser *p)
 {
-	/* IDENTIFIER '{' VALUE* '}' */
+	/* IDENTIFIER TOK_SECTION_B_CHAR VALUE* TOK_SECTION_E_CHAR */
 	struct config_node *root, *n, *l = NULL;
 	if (!(root = _create_node(p))) {
 		stack;
@@ -623,12 +626,12 @@ static void _get_token(struct parser *p,
 	p->t = TOK_INT;		/* fudge so the fall through for
 				   floats works */
 	switch (*p->te) {
-	case '{':
+	case TOK_SECTION_B_CHAR:
 		p->t = TOK_SECTION_B;
 		p->te++;
 		break;
 
-	case '}':
+	case TOK_SECTION_E_CHAR:
 		p->t = TOK_SECTION_E;
 		p->te++;
 		break;
@@ -708,8 +711,9 @@ static void _get_token(struct parser *p,
 	default:
 		p->t = TOK_IDENTIFIER;
 		while ((p->te != p->fe) && (*p->te) && !isspace(*p->te) &&
-		       (*p->te != '#') && (*p->te != '=') && (*p->te != '{') &&
-		       (*p->te != '}'))
+		       (*p->te != '#') && (*p->te != '=') &&
+		       (*p->te != TOK_SECTION_B_CHAR) &&
+		       (*p->te != TOK_SECTION_E_CHAR))
 			p->te++;
 		break;
 	}
@@ -1146,3 +1150,61 @@ int merge_config_tree(struct cmd_context
 
 	return 1;
 }
+
+/*
+ * Convert a token type to the char it represents.
+ */
+static char _token_type_to_char(int type)
+{
+	switch (type) {
+		case TOK_SECTION_B:
+			return TOK_SECTION_B_CHAR;
+		case TOK_SECTION_E:
+			return TOK_SECTION_E_CHAR;
+		default:
+			return 0;
+	}
+}
+
+/*
+ * Returns:
+ *  # of 'type' tokens in 'str'.
+ */
+static unsigned _count_tokens (char *str, unsigned len, int type)
+{
+	unsigned i;
+	unsigned count=0;
+	char c;
+
+	c = _token_type_to_char(type);
+
+	for (i=0; i<len; i++)
+		if (str[i] == c)
+			count++;
+	return count;
+}
+
+/*
+ * Determine whether a text region  contains a valid "section".
+ * A valid section is defined by an equal number of non-zero begin
+ * and end section tokens.
+ *
+ * Returns:
+ *  0 - not a section
+ *  1 - is a section
+ */
+unsigned is_config_section(char *str, unsigned len)
+{
+	int begin_count;
+	int end_count;
+
+	begin_count = _count_tokens(str, len, TOK_SECTION_B);
+	end_count = _count_tokens(str, len, TOK_SECTION_E);
+
+	if ((begin_count != 0)&&(end_count != 0)&&
+	    (begin_count - end_count == 0))
+		return 1;
+	else
+		return 0;
+}
+
Index: LVM2/lib/config/config.h
===================================================================
--- LVM2.orig/lib/config/config.h	2007-04-17 13:11:08.000000000 -0400
+++ LVM2/lib/config/config.h	2007-04-17 13:15:12.000000000 -0400
@@ -108,4 +108,6 @@ int get_config_uint64(const struct confi
 int get_config_str(const struct config_node *cn, const char *path,
 		   char **result);
 
+unsigned is_config_section(char *str, unsigned len);
+
 #endif
Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW	2007-04-17 13:11:08.000000000 -0400
+++ LVM2/WHATS_NEW	2007-04-17 13:15:12.000000000 -0400
@@ -1,6 +1,6 @@
 Version 2.02.25 -
 =================================
-  Add dev_read2.
+  Add dev_read2, lib/config support functions.
   Add pvck command stub.
   Update lists of attribute characters in man pages.
   Change cling alloc policy attribute character from 'C' to l'.



