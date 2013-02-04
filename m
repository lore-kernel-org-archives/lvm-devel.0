From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Feb 2013 18:07:55 +0000 (UTC)
Subject: master - libdm: fix segault for truncated string token.
Message-ID: <20130204180755.BE7213523@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f439707fd4a8837f930c14076bc662ca5c19844
Commit:        4f439707fd4a8837f930c14076bc662ca5c19844
Parent:        9f433e6ee34c0ff94017c940aac301bc28d7e233
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 1 11:07:44 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 4 19:01:10 2013 +0100

libdm: fix segault for truncated string token.

This patch fixes problem reported here:

https://www.redhat.com/archives/dm-devel/2013-January/msg00311.html

Fixing it by separating function for duplicating string token.

---
When /etc/lvm/lvm.conf is truncated at the first '"' of a line, all LVM
utilities crash with a segfault.

The segfault only seems to occur if the last character is the first '"'
(double quote) of a line. If you truncate it at any other point, lvm
detects the error and report parse error

lvm.conf ends like this.

$hexdump -C lvm.conf
....
69 72 20 3d 20 22 2f 64  65 76 22 0a 0a 0a 20 20  |ir = "/dev"...  |
20 20 23 20 41 6e 20 61  72 72 61 79 20 6f 66 20  |  # An array of |
64 69 72 65 63 74 6f 72  69 65 73 20 74 68 61 74  |directories that|
20 63 6f 6e 74 61 69 6e  20 74 68 65 20 64 65 76  | contain the dev|
69 63 65 20 6e 6f 64 65  73 20 79 6f 75 20 77 69  |ice nodes you wi|
73 68 0a 20 20 20 20 23  20 74 6f 20 75 73 65 20  |sh.    # to use |
77 69 74 68 20 4c 56 4d  32 2e 0a 20 20 20 20 73  |with LVM2..    s|
63 61 6e 20 3d 20 5b 20  22 2f 78 22 2c 0a 20 20  |can = [ "/x",.  |
20 20 20 20 20 20 20 20  20 20 20 22              | "|
...

Reported-by: dongmao zhang <dmzhang suse com>
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-config.c |   30 ++++++++++++++++++++++++------
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 12ba71e..2b820e1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Fix segfault for truncated string token in config file after the first '"'.
   Close open dmeventd FIFO file descriptors on exec (FD_CLOEXEC).
   Fix resource leak in error path of dmeventd's umount of thin volume.
   Automatically deactivate failed preloaded dm tree node.
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index c19f51d..cc726ae 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -360,6 +360,27 @@ int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline,
 /*
  * parser
  */
+static char *_dup_string_tok(struct parser *p)
+{
+	char *str;
+
+	p->tb++, p->te--;	/* strip "'s */
+
+	if (p->te < p->tb) {
+		log_error("Parse error at byte %" PRIptrdiff_t " (line %d): "
+			  "expected a string token.",
+			  p->tb - p->fb + 1, p->line);
+		return NULL;
+	}
+
+	if (!(str = _dup_tok(p)))
+		return_NULL;
+
+	p->te++;
+
+	return str;
+}
+
 static struct dm_config_node *_file(struct parser *p)
 {
 	struct dm_config_node *root = NULL, *n, *l = NULL;
@@ -480,22 +501,19 @@ static struct dm_config_value *_type(struct parser *p)
 	case TOK_STRING:
 		v->type = DM_CFG_STRING;
 
-		p->tb++, p->te--;	/* strip "'s */
-		if (!(v->v.str = _dup_tok(p)))
+		if (!(v->v.str = _dup_string_tok(p)))
 			return_NULL;
-		p->te++;
+
 		match(TOK_STRING);
 		break;
 
 	case TOK_STRING_ESCAPED:
 		v->type = DM_CFG_STRING;
 
-		p->tb++, p->te--;	/* strip "'s */
-		if (!(str = _dup_tok(p)))
+		if (!(str = _dup_string_tok(p)))
 			return_NULL;
 		dm_unescape_double_quotes(str);
 		v->v.str = str;
-		p->te++;
 		match(TOK_STRING_ESCAPED);
 		break;
 


