From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:53:07 +0000 (UTC)
Subject: master - libdm-config: Warn about duplicate keys.
Message-ID: <20141120155307.38C8E60DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0050480c0eced1da98ffc76d5010cef605c776eb
Commit:        0050480c0eced1da98ffc76d5010cef605c776eb
Parent:        de2c5ab2ac0100c1d2f0648b9fec5304371a1ae5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Nov 20 16:18:22 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:06 2014 +0100

libdm-config: Warn about duplicate keys.

---
 libdm/libdm-config.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index e99ae26..93e2887 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -523,6 +523,7 @@ static struct dm_config_node *_section(struct parser *p, struct dm_config_node *
 	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
 
 	struct dm_config_node *root, *n, *l = NULL;
+	struct dm_config_value *value;
 	char *str;
 
 	if (p->t == TOK_STRING_ESCAPED) {
@@ -560,8 +561,12 @@ static struct dm_config_node *_section(struct parser *p, struct dm_config_node *
 		match(TOK_SECTION_E);
 	} else {
 		match(TOK_EQ);
-		if (!(root->v = _value(p)))
+		if (!(value = _value(p)))
 			return_NULL;
+		if (root->v)
+			log_warn("WARNING: Ignoring duplicate"
+				 " config value: %s", str);
+		root->v = value;
 	}
 
 	return root;


