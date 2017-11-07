From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 15:36:22 -0500
Subject: master - coverity: add some initilizers
Message-ID: <201711072036.vA7KaMlo008043@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c9e3e8df25e4c8239945de7ea3629426ffe08bb
Commit:        0c9e3e8df25e4c8239945de7ea3629426ffe08bb
Parent:        3076a839a507196548b664ac9fd2307d7fbdb47e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 7 20:54:51 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 7 21:26:11 2017 +0100

coverity: add some initilizers

Coverity cannot do a deeper analyzis so let's make just reports
go away and initialize them to 0.
---
 daemons/dmeventd/dmeventd.c |    1 +
 lib/activate/dev_manager.c  |    2 +-
 libdm/libdm-report.c        |    2 +-
 tools/lvconvert.c           |    8 ++++----
 tools/toollib.c             |    6 +++---
 5 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index cc520d3..7ad7f81 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -865,6 +865,7 @@ static int _event_wait(struct thread_status *thread)
 	 * This is so that you can break out of waiting on an event,
 	 * either for a timeout event, or to cancel the thread.
 	 */
+	sigemptyset(&old);
 	sigemptyset(&set);
 	sigaddset(&set, SIGALRM);
 	if (pthread_sigmask(SIG_UNBLOCK, &set, &old) != 0) {
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9b98c92..29727df 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1787,7 +1787,7 @@ struct pool_cb_data {
 static int _pool_callback(struct dm_tree_node *node,
 			  dm_node_callback_t type, void *cb_data)
 {
-	int ret, status, fd;
+	int ret, status = 0, fd;
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 	const struct pool_cb_data *data = cb_data;
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 05f5ea0..6d140af 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2626,7 +2626,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 							    "for selection field %s.";
 	struct selection_str_list *ssl = NULL;
 	struct dm_str_list *item;
-	const char *begin_item, *end_item, *tmp;
+	const char *begin_item = NULL, *end_item = NULL, *tmp;
 	uint32_t op_flags, end_op_flag_expected, end_op_flag_hit = 0;
 	struct dm_str_list **arr;
 	size_t list_size;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 50c77d8..8480072 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1158,10 +1158,10 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 			      struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
-	uint32_t old_mimage_count;
-	uint32_t old_log_count;
-	uint32_t new_mimage_count;
-	uint32_t new_log_count;
+	uint32_t old_mimage_count = 0;
+	uint32_t old_log_count = 0;
+	uint32_t new_mimage_count = 0;
+	uint32_t new_log_count = 0;
 
 	if ((lp->corelog || lp->mirrorlog) && *lp->type_str && strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
 		log_error("--corelog and --mirrorlog are only compatible with mirror devices.");
diff --git a/tools/toollib.c b/tools/toollib.c
index 7eb0bed..3b89568 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2723,9 +2723,9 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 	char buf[64];
 	struct cmd_rule *rule;
 	struct lv_type *lvtype = NULL;
-	uint64_t lv_props_match_bits, lv_props_unmatch_bits;
-	uint64_t lv_types_match_bits, lv_types_unmatch_bits;
-	int opts_match_count, opts_unmatch_count;
+	uint64_t lv_props_match_bits = 0, lv_props_unmatch_bits = 0;
+	uint64_t lv_types_match_bits = 0, lv_types_unmatch_bits = 0;
+	int opts_match_count = 0, opts_unmatch_count = 0;
 	int lvt_enum;
 	int ret = 1;
 	int i;


