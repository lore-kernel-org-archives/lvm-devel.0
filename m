From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Apr 2014 10:30:18 +0000 (UTC)
Subject: dev-prajnoha-selout - selout: make regex selection to work without quotes and recognize regex op before equal op
Message-ID: <20140430103018.75FD160F51@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f36abf589827adda359acfe8b4dff80301afa6ed
Commit:        f36abf589827adda359acfe8b4dff80301afa6ed
Parent:        61570324d975b1fbf3fad1da10c792f7992f7044
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 30 12:29:48 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 30 12:29:48 2014 +0200

selout: make regex selection to work without quotes and recognize regex op before equal op

---
 libdm/libdm-report.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index ac0be67..f5fea50 100644
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
 
@@ -1141,15 +1146,18 @@ static const char *_tok_regex(const char *s,
 		case '(': c = ')'; break;
 		case '{': c = '}'; break;
 		case '[': c = ']'; break;
-		default:  c = *s;
+		default:  c = 0;
 	}
 
 	s = _tok_string(s + 1, begin, end, c);
-	if (!*s) {
-		log_error("Missing end quote of regex");
-		return NULL;
+	if ((c = *s)) {
+		if (c && (c != ')') && (c != '}') && (c != ']'))
+		{
+			log_error("Missing end quote of regex");
+			return NULL;
+		}
+		s++;
 	}
-	s++;
 
 	*flags |= DM_REPORT_FIELD_TYPE_STRING;
 


