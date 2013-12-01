From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun,  1 Dec 2013 21:16:03 +0000 (UTC)
Subject: master - libdm-config: Allow quoted section (and key) names.
Message-ID: <20131201211603.3610360FCA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c35394959758ec17389529f95a33bf7f5b15c56b
Commit:        c35394959758ec17389529f95a33bf7f5b15c56b
Parent:        2e82a070f3c9224da5c9f383d47e75a1715586cf
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Dec 1 20:02:28 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Dec 1 20:57:42 2013 +0100

libdm-config: Allow quoted section (and key) names.

---
 libdm/libdm-config.c |   22 +++++++++++++++++++---
 1 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 3385e18..fbee007 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -287,6 +287,7 @@ static int _write_config(const struct dm_config_node *n, int only_one,
 	char space[MAX_INDENT + 1];
 	int l = (level < MAX_INDENT) ? level : MAX_INDENT;
 	int i;
+	char *escaped_key = NULL;
 
 	if (!n)
 		return 1;
@@ -301,7 +302,14 @@ static int _write_config(const struct dm_config_node *n, int only_one,
 
 		if (!_line_start(out))
 			return_0;
-		line_append("%s%s", space, n->key);
+		if (strchr(n->key, '#') || strchr(n->key, '"') || strchr(n->key, '!')) {
+			escaped_key = alloca(dm_escaped_len(n->key) + 2);
+			*escaped_key = '"';
+			dm_escape_double_quotes(escaped_key + 1, n->key);
+			strcat(escaped_key, "\"");
+		}
+		line_append("%s%s", space, escaped_key ? escaped_key : n->key);
+		escaped_key = NULL;
 		if (!n->v) {
 			/* it's a sub section */
 			line_append(" {");
@@ -433,15 +441,23 @@ static struct dm_config_node *_section(struct parser *p)
 {
 	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
 	struct dm_config_node *root, *n, *l = NULL;
+	char *token;
 	if (!(root = _create_node(p->mem))) {
 		log_error("Failed to allocate section node");
 		return NULL;
 	}
 
-	if (!(root->key = _dup_tok(p)))
+	if (!(root->key = token = _dup_tok(p)))
 		return_NULL;
 
-	match(TOK_IDENTIFIER);
+	if (p->t == TOK_STRING_ESCAPED) {
+		token ++; /* OK as the token is pool-allocated */
+		token[strlen(token) - 1] = 0;
+		dm_unescape_double_quotes(token);
+		root->key = token;
+		match(TOK_STRING_ESCAPED);
+	} else
+		match(TOK_IDENTIFIER);
 
 	if (p->t == TOK_SECTION_B) {
 		match(TOK_SECTION_B);


