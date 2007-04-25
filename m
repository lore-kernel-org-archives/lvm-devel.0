From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Apr 2007 20:38:40 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c lib/confi ...
Message-ID: <20070425203840.25789.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-04-25 21:38:39

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c config.h 

Log message:
	Add support functions for analysis of config sections,
	and hence, on-disk LVM2 metadata.
	
	--

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.603&r2=1.604
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2007/04/25 20:03:15	1.603
+++ LVM2/WHATS_NEW	2007/04/25 20:38:39	1.604
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Add support functions for analysis of config sections
   Update pvck to read labels on disk, with --labelsector parameter
   Add count_chars and count_chars_len functions
   Add /sys/block listings to lvm_dump.sh
--- LVM2/lib/config/config.c	2007/04/19 02:10:42	1.55
+++ LVM2/lib/config/config.c	2007/04/25 20:38:39	1.56
@@ -19,6 +19,7 @@
 #include "device.h"
 #include "str_list.h"
 #include "toolcontext.h"
+#include "lvm-string.h"
 
 #include <sys/stat.h>
 #include <sys/mman.h>
@@ -26,6 +27,9 @@
 #include <fcntl.h>
 #include <ctype.h>
 
+#define SECTION_B_CHAR '{'
+#define SECTION_E_CHAR '}'
+
 enum {
 	TOK_INT,
 	TOK_FLOAT,
@@ -474,7 +478,7 @@
 
 static struct config_node *_section(struct parser *p)
 {
-	/* IDENTIFIER '{' VALUE* '}' */
+	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
 	struct config_node *root, *n, *l = NULL;
 	if (!(root = _create_node(p))) {
 		stack;
@@ -623,12 +627,12 @@
 	p->t = TOK_INT;		/* fudge so the fall through for
 				   floats works */
 	switch (*p->te) {
-	case '{':
+	case SECTION_B_CHAR:
 		p->t = TOK_SECTION_B;
 		p->te++;
 		break;
 
-	case '}':
+	case SECTION_E_CHAR:
 		p->t = TOK_SECTION_E;
 		p->te++;
 		break;
@@ -708,8 +712,9 @@
 	default:
 		p->t = TOK_IDENTIFIER;
 		while ((p->te != p->fe) && (*p->te) && !isspace(*p->te) &&
-		       (*p->te != '#') && (*p->te != '=') && (*p->te != '{') &&
-		       (*p->te != '}'))
+		       (*p->te != '#') && (*p->te != '=') &&
+		       (*p->te != SECTION_B_CHAR) &&
+		       (*p->te != SECTION_E_CHAR))
 			p->te++;
 		break;
 	}
@@ -1146,3 +1151,61 @@
 
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
+			return SECTION_B_CHAR;
+		case TOK_SECTION_E:
+			return SECTION_E_CHAR;
+		default:
+			return 0;
+	}
+}
+
+/*
+ * Returns:
+ *  # of 'type' tokens in 'str'.
+ */
+static unsigned _count_tokens (const char *str, unsigned len, int type)
+{
+	char c;
+
+	c = _token_type_to_char(type);
+
+	return(count_chars_len(str, len, c));
+}
+
+/*
+ * Heuristic function to make a quick guess as to whether a text
+ * region probably contains a valid config "section".  (Useful for
+ * scanning areas of the disk for old metadata.)
+ * Config sections contain various tokens, may contain other sections
+ * and strings, and are delimited by begin (type 'TOK_SECTION_B') and
+ * end (type 'TOK_SECTION_E') tokens.  As a quick heuristic, we just
+ * count the number of begin and end tokens, and see if they are
+ * non-zero and the counts match.
+ * Full validation of the section should be done with another function
+ * (for example, read_config_fd).
+ *
+ * Returns:
+ *  0 - probably is not a valid config section
+ *  1 - probably _is_ a valid config section
+ */
+unsigned maybe_config_section(const char *str, unsigned len)
+{
+	int begin_count;
+	int end_count;
+
+	begin_count = _count_tokens(str, len, TOK_SECTION_B);
+	end_count = _count_tokens(str, len, TOK_SECTION_E);
+
+	if (begin_count && end_count && (begin_count - end_count == 0))
+		return 1;
+	else
+		return 0;
+}
--- LVM2/lib/config/config.h	2007/01/09 23:22:31	1.22
+++ LVM2/lib/config/config.h	2007/04/25 20:38:39	1.23
@@ -108,4 +108,6 @@
 int get_config_str(const struct config_node *cn, const char *path,
 		   char **result);
 
+unsigned maybe_config_section(const char *str, unsigned len);
+
 #endif


