From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:57:06 +0000 (UTC)
Subject: dev-prajnoha-selout - selout: make regex selection to work without quotes and recognize regex op before equal op
Message-ID: <20140509065706.D446D60DED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c08ea56c7b454a176ae50efff335f5799b08fc32
Commit:        c08ea56c7b454a176ae50efff335f5799b08fc32
Parent:        f97385a31e1ded0e4a198fc40ddb9e40da383445
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 30 12:29:48 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri May 9 08:51:00 2014 +0200

selout: make regex selection to work without quotes and recognize regex op before equal op

---
 libdm/libdm-report.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 47f4d4f..aceb310 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -87,15 +87,20 @@ struct op_def {
 #define FLD_CMP_LT	0x00008000
 #define FLD_CMP_REGEX	0x00010000
 
+/*
+ * When defining operators, always define longer one before
+ * shorter one if one is a prefix of another!
+ * (e.g. =~ comes before =)
+ */
 static struct op_def _op_cmp[] = {
+	{ "=~", FLD_CMP_REGEX, "Matching regular expression" },
+	{ "!~", FLD_CMP_REGEX|FLD_CMP_NOT, "Not matching regular expression" },
 	{ "=", FLD_CMP_EQUAL, "Equal to" },
 	{ "!=", FLD_CMP_NOT|FLD_CMP_EQUAL, "Not equal" },
 	{ ">=", FLD_CMP_GT|FLD_CMP_EQUAL, "Greater than or equal to" },
 	{ ">", FLD_CMP_GT, "Greater than" },
 	{ "<=", FLD_CMP_LT|FLD_CMP_EQUAL, "Lesser than or equal to" },
 	{ "<", FLD_CMP_LT, "Lesser than" },
-	{ "=~", FLD_CMP_REGEX, "Matching regular expression" },
-	{ "!~", FLD_CMP_REGEX|FLD_CMP_NOT, "Not matching regular expression" },
 	{ NULL, 0, NULL }
 };
 
@@ -1145,15 +1150,18 @@ static const char *_tok_regex(const struct dm_report_field_type *ft,
 		case '(': c = ')'; break;
 		case '{': c = '}'; break;
 		case '[': c = ']'; break;
-		default:  c = *s;
+		default:  c = 0;
 	}
 
 	s = _tok_string(s + 1, begin, end, c);
-	if (!*s) {
-		log_error("Missing end quote of regex for field %s", ft->id);
-		return NULL;
+	if ((c = *s)) {
+		if (c && (c != ')') && (c != '}') && (c != ']'))
+		{
+			log_error("Missing end quote of regex for field %s", ft->id);
+			return NULL;
+		}
+		s++;
 	}
-	s++;
 
 	*flags |= DM_REPORT_FIELD_TYPE_STRING;
 


