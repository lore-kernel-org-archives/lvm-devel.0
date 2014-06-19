From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 19 Jun 2014 14:17:51 +0000 (UTC)
Subject: master - select: add list of allowed types for each selection operator mentioned in help
Message-ID: <20140619141751.AF83F6063F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=012dab7aa3373201e59a77fa1e11823bd95c771c
Commit:        012dab7aa3373201e59a77fa1e11823bd95c771c
Parent:        b33091cb115ccc11741344716756e522ebad8e48
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 19 15:19:54 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 19 15:19:54 2014 +0200

select: add list of allowed types for each selection operator mentioned in help

---
 libdm/libdm-report.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 867bf44..00b99c8 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -103,14 +103,14 @@ struct op_def {
  * (e.g. =~ comes before =)
 */
 static struct op_def _op_cmp[] = {
-	{ "=~", FLD_CMP_REGEX, "Matching regular expression." },
-	{ "!~", FLD_CMP_REGEX|FLD_CMP_NOT, "Not matching regular expression." },
-	{ "=", FLD_CMP_EQUAL, "Equal to." },
-	{ "!=", FLD_CMP_NOT|FLD_CMP_EQUAL, "Not equal to." },
-	{ ">=", FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL, "Greater than or equal to." },
-	{ ">", FLD_CMP_NUMBER|FLD_CMP_GT, "Greater than" },
-	{ "<=", FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL, "Less than or equal to." },
-	{ "<", FLD_CMP_NUMBER|FLD_CMP_LT, "Less than." },
+	{ "=~", FLD_CMP_REGEX, "Matching regular expression. [regex]" },
+	{ "!~", FLD_CMP_REGEX|FLD_CMP_NOT, "Not matching regular expression. [regex]" },
+	{ "=", FLD_CMP_EQUAL, "Equal to. [number, size, percent, string, string list]" },
+	{ "!=", FLD_CMP_NOT|FLD_CMP_EQUAL, "Not equal to. [number, size, percent, string, string_list]" },
+	{ ">=", FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL, "Greater than or equal to. [number, size, percent]" },
+	{ ">", FLD_CMP_NUMBER|FLD_CMP_GT, "Greater than. [number, size, percent]" },
+	{ "<=", FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL, "Less than or equal to. [number, size, percent]" },
+	{ "<", FLD_CMP_NUMBER|FLD_CMP_LT, "Less than. [number, size, percent]" },
 	{ NULL, 0, NULL }
 };
 


