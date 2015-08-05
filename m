From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  5 Aug 2015 07:30:28 +0000 (UTC)
Subject: master - libdm: Whitespace.
Message-ID: <20150805073028.4FEBB6036F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88551add9725ab9a6866bce2cd1e4428078d76d1
Commit:        88551add9725ab9a6866bce2cd1e4428078d76d1
Parent:        23e8e849e47284b3e5db815767d2d47765579986
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 5 05:11:42 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 5 05:11:42 2015 +0100

libdm: Whitespace.

---
 libdm/libdm-report.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 225da90..1c4d221 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -154,18 +154,18 @@ static struct op_def _op_cmp[] = {
 #define SEL_LIST_SUBSET_LE	0x00080000
 
 static struct op_def _op_log[] = {
-        { "&&", SEL_AND, "All fields must match" },
+	{ "&&", SEL_AND, "All fields must match" },
 	{ ",", SEL_AND, "All fields must match" },
-        { "||", SEL_OR, "At least one field must match" },
+	{ "||", SEL_OR, "At least one field must match" },
 	{ "#", SEL_OR, "At least one field must match" },
-        { "!", SEL_MODIFIER_NOT, "Logical negation" },
-        { "(", SEL_PRECEDENCE_PS, "Left parenthesis" },
-        { ")", SEL_PRECEDENCE_PE, "Right parenthesis" },
-        { "[", SEL_LIST_LS, "List start" },
-        { "]", SEL_LIST_LE, "List end"},
-        { "{", SEL_LIST_SUBSET_LS, "List subset start"},
-        { "}", SEL_LIST_SUBSET_LE, "List subset end"},
-        { NULL,  0, NULL},
+	{ "!", SEL_MODIFIER_NOT, "Logical negation" },
+	{ "(", SEL_PRECEDENCE_PS, "Left parenthesis" },
+	{ ")", SEL_PRECEDENCE_PE, "Right parenthesis" },
+	{ "[", SEL_LIST_LS, "List start" },
+	{ "]", SEL_LIST_LE, "List end"},
+	{ "{", SEL_LIST_SUBSET_LS, "List subset start"},
+	{ "}", SEL_LIST_SUBSET_LE, "List subset end"},
+	{ NULL,  0, NULL},
 };
 
 struct selection_str_list {


