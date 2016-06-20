From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:50 +0000 (UTC)
Subject: master - report: add _get_report_idx_from_name and _should_process_report_idx helper fns
Message-ID: <20160620094050.91C7460F36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80ffaefb88917f77eafdf36dd4f882cc65706050
Commit:        80ffaefb88917f77eafdf36dd4f882cc65706050
Parent:        28b4c48e2ae66b87bbb5d8fd29b761edba63a90e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 26 15:50:52 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

report: add _get_report_idx_from_name and _should_process_report_idx helper fns

Prepare for recognition of cmd line options for each subreport within
one command.
---
 tools/reporter.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 408d410..103ae2c 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -723,6 +723,47 @@ static void _del_option_from_list(struct dm_list *sll, const char *prefix,
 	}
 }
 
+#define _get_report_idx(report_type,single_report_type) \
+	(((report_type != FULL) && (report_type == single_report_type)) ? REPORT_IDX_SINGLE : REPORT_IDX_FULL_ ## single_report_type)
+
+static report_idx_t _get_report_idx_from_name(report_type_t report_type, const char *name)
+{
+	report_idx_t idx;
+
+	if (!name || !*name)
+		return REPORT_IDX_NULL;
+
+	if (!strcasecmp(name, "log"))
+		idx = REPORT_IDX_LOG;
+	else if (!strcasecmp(name, "vg"))
+		idx = _get_report_idx(report_type, VGS);
+	else if (!strcasecmp(name, "pv"))
+		idx = _get_report_idx(report_type, PVS);
+	else if (!strcasecmp(name, "lv"))
+		idx = _get_report_idx(report_type, LVS);
+	else if (!strcasecmp(name, "pvseg"))
+		idx = _get_report_idx(report_type, PVSEGS);
+	else if (!strcasecmp(name, "seg"))
+		idx = _get_report_idx(report_type, SEGS);
+	else {
+		idx = REPORT_IDX_NULL;
+		log_error("Unknonwn report specifier in "
+			  "report option list: %s.", name);
+	}
+
+	return idx;
+}
+
+static int _should_process_report_idx(report_type_t report_type, report_idx_t idx)
+{
+	if (((idx == REPORT_IDX_LOG) && (report_type != CMDLOG)) ||
+	    ((idx == REPORT_IDX_SINGLE) && ((report_type == FULL) || (report_type == CMDLOG))) ||
+	    ((idx > REPORT_IDX_LOG) && report_type != FULL))
+		return 0;
+
+	return 1;
+}
+
 static int _get_report_options(struct cmd_context *cmd,
 			       struct report_args *args,
 			       struct single_report_args *single_args)


