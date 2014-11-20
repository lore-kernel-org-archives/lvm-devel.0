From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:53:03 +0000 (UTC)
Subject: master - libdm-config: Interpret barewords after '=' as strings.
Message-ID: <20141120155303.0635760EDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bc996676345bdaa69e0bdaaebb490a9da5a7d4b
Commit:        8bc996676345bdaa69e0bdaaebb490a9da5a7d4b
Parent:        274a7a68b80fdce9e9398ffbe45e788b13b04642
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Nov 19 18:48:47 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:06 2014 +0100

libdm-config: Interpret barewords after '=' as strings.

---
 libdm/libdm-config.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index e6b2b90..1bc88e1 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -30,6 +30,7 @@ enum {
 	TOK_FLOAT,
 	TOK_STRING,		/* Single quotes */
 	TOK_STRING_ESCAPED,	/* Double quotes */
+	TOK_STRING_BARE,	/* No quotes */
 	TOK_EQ,
 	TOK_SECTION_B,
 	TOK_SECTION_E,
@@ -638,6 +639,15 @@ static struct dm_config_value *_type(struct parser *p)
 		match(TOK_STRING);
 		break;
 
+	case TOK_STRING_BARE:
+		v->type = DM_CFG_STRING;
+
+		if (!(v->v.str = _dup_tok(p)))
+			return_NULL;
+
+		match(TOK_STRING_BARE);
+		break;
+
 	case TOK_STRING_ESCAPED:
 		v->type = DM_CFG_STRING;
 
@@ -783,6 +793,8 @@ static void _get_token(struct parser *p, int tok_prev)
 		       (*te != SECTION_B_CHAR) &&
 		       (*te != SECTION_E_CHAR))
 			te++;
+		if (values_allowed)
+			p->t = TOK_STRING_BARE;
 		break;
 	}
 


