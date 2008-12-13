From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 12 Dec 2008 21:01:36 -0500
Subject: [PATCH] Fix segfault when invalid field given in reporting commands.
Message-ID: <1229133696-1439-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Problem is dm_report_init() may return NULL and subsequent call to
dm_report_set_output_field_name_prefix() doesn't handle NULL value.

Example:
	pvs --nameprefixes --rows --unquoted --noheadings -opv_name,fred
  Logical Volume Fields
  ---------------------
    lv_uuid              - Unique identifier
    lv_name              - Name.  LVs created for internal use are enclosed in brackets.
 ...

  Physical Volume Segment Fields
  ------------------------------
    pvseg_start          - Physical Extent number of start of segment.
    pvseg_size           - Number of extents in segment.

  Unrecognised field: fred
Segmentation fault

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 4c164c9..a439c80 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1108,7 +1108,7 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 	rh = dm_report_init(report_type, _report_types, _fields, format,
 			    separator, report_flags, keys, cmd);
 
-	if (field_prefixes)
+	if (rh && field_prefixes)
 		dm_report_set_output_field_name_prefix(rh, "lvm2_");
 
 	return rh;
-- 
1.5.5.1


