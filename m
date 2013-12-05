From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  5 Dec 2013 01:14:52 +0000 (UTC)
Subject: master - libdm: prevent empty config file section names
Message-ID: <20131205011452.7C0BA603A0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6d3fd62fc87bcdc6a12b7751e36a6a84b0bb62d
Commit:        b6d3fd62fc87bcdc6a12b7751e36a6a84b0bb62d
Parent:        76ca82df827c83c475a4eb8edb7bb670528cf6e7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Dec 5 01:09:03 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Dec 5 01:09:03 2013 +0000

libdm: prevent empty config file section names

Change c35394959758ec17389529f95a33bf7f5b15c56b to use existing
_dup_string_tok().  alloca() doesn't fail cleanly (and needs
replacing.)
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-config.c |   40 ++++++++++++++++++++++++++--------------
 2 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1f1cde1..b737a3e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.84 -
 ====================================
+  Allow section names in config file data to be quoted strings.
   Close fifos before exiting in dmeventd restart() error path.
   Move printf format string directly into dm_asprintf args list.
   Catch invalid use of string sort values when reporting numerical fields.
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index fbee007..ea1af2f 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -253,11 +253,7 @@ static int _write_value(struct config_output *out, const struct dm_config_value
 
 	switch (v->type) {
 	case DM_CFG_STRING:
-		if (!(buf = alloca(dm_escaped_len(v->v.str)))) {
-			log_error("temporary stack allocation for a config "
-				  "string failed");
-			return 0;
-		}
+		buf = alloca(dm_escaped_len(v->v.str));
 		line_append("\"%s\"", dm_escape_double_quotes(buf, v->v.str));
 		break;
 
@@ -440,24 +436,40 @@ static struct dm_config_node *_file(struct parser *p)
 static struct dm_config_node *_section(struct parser *p)
 {
 	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
+
 	struct dm_config_node *root, *n, *l = NULL;
-	char *token;
+	char *str;
+
 	if (!(root = _create_node(p->mem))) {
 		log_error("Failed to allocate section node");
 		return NULL;
 	}
 
-	if (!(root->key = token = _dup_tok(p)))
-		return_NULL;
-
 	if (p->t == TOK_STRING_ESCAPED) {
-		token ++; /* OK as the token is pool-allocated */
-		token[strlen(token) - 1] = 0;
-		dm_unescape_double_quotes(token);
-		root->key = token;
+		if (!(str = _dup_string_tok(p)))
+			return_NULL;
+		dm_unescape_double_quotes(str);
+		root->key = str;
+
 		match(TOK_STRING_ESCAPED);
-	} else
+	} else if (p->t == TOK_STRING) {
+		if (!(str = _dup_string_tok(p)))
+			return_NULL;
+		root->key = str;
+
+		match(TOK_STRING);
+	} else {
+		if (!(root->key = _dup_tok(p)))
+			return_NULL;
+
 		match(TOK_IDENTIFIER);
+	}
+
+	if (!strlen(root->key)) {
+		log_error("Parse error at byte %" PRIptrdiff_t " (line %d): empty section identifier",
+			  p->tb - p->fb + 1, p->line);
+		return NULL;
+	}
 
 	if (p->t == TOK_SECTION_B) {
 		match(TOK_SECTION_B);


