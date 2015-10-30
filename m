From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:30 +0000 (UTC)
Subject: master - report: support "-o -field_name1, field_name2, ...."
Message-ID: <20151030145230.419ED609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e18b101a0845f826de29cfd0c554c5e2be2baa5
Commit:        3e18b101a0845f826de29cfd0c554c5e2be2baa5
Parent:        df190dcfa58ee3c7cc9959da6af3ae22e9618992
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 21 15:36:26 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:56 2015 +0100

report: support "-o -field_name1,field_name2,...."

---
 tools/reporter.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index f053b08..591f4ed 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -604,11 +604,26 @@ static void _check_pv_list(struct cmd_context *cmd, int argc, char **argv,
 	}
 }
 
+static void _del_option_from_list(struct dm_list *sll, const char *str)
+{
+	struct dm_list *slh;
+	struct dm_str_list *sl;
+
+	dm_list_uniterate(slh, sll, sll) {
+		sl = dm_list_item(slh, struct dm_str_list);
+		if (!strcmp(str, sl->str)) {
+			dm_list_del(slh);
+			return;
+		}
+	}
+}
+
 static int _get_report_options(struct cmd_context *cmd, const char **options)
 {
 	struct arg_value_group_list *current_group;
 	struct dm_list *final_opts_list;
 	struct dm_list *opts_list = NULL;
+	struct dm_str_list *sl;
 	const char *opts;
 	int r = ECMD_PROCESSED;
 
@@ -630,11 +645,18 @@ static int _get_report_options(struct cmd_context *cmd, const char **options)
 
 		switch (*opts) {
 			case '+':
+				/* fall through */
+			case '-':
 				if (!(opts_list = str_to_str_list(NULL, opts + 1, ",", 1))) {
 					r = ECMD_FAILED;
 					goto_out;
 				}
-				dm_list_splice(final_opts_list, opts_list);
+				if (*opts == '+') {
+					dm_list_splice(final_opts_list, opts_list);
+				} else if (*opts == '-') {
+					dm_list_iterate_items(sl, opts_list)
+						_del_option_from_list(final_opts_list, sl->str);
+				}
 				str_list_destroy(opts_list, 1);
 				opts_list = NULL;
 				break;


