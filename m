From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 15 May 2014 09:03:15 +0000 (UTC)
Subject: master - report: export DM_REPORT_FIELD_RESERVED_NAME_{HELP, HELP_ALT} and show help on '<lvm_command> -O help'
Message-ID: <20140515090315.530D960B36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c86131233011c9fb81190bcb40d5d4ac54a533d
Commit:        7c86131233011c9fb81190bcb40d5d4ac54a533d
Parent:        5684cfcb1c13129b70ddaf1ee4df95e08bc551a9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 15 10:58:05 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu May 15 10:58:14 2014 +0200

report: export DM_REPORT_FIELD_RESERVED_NAME_{HELP,HELP_ALT} and show help on '<lvm_command> -O help'

Share DM_REPORT_FIELD_RESERVED_NAME_{HELP,HELP_ALT} between libdm and
any libdm user to handle reserved field names, in this case the virtual
field name to show help instead of failing on unrecognized field.
The libdm user also needs to check the field name so it can fire
proper code in this case (cleanup, exit etc.).
---
 WHATS_NEW            |    1 +
 WHATS_NEW_DM         |    2 ++
 libdm/libdevmapper.h |    4 ++++
 libdm/libdm-report.c |   11 ++++++++---
 tools/reporter.c     |    5 ++++-
 5 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c5cbf37..090e914 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Make reporting commands show help about possible sort keys on '-O help'.
   Add metadata_percent to lvs_cols.
   Take account of parity areas with alloc anywhere in _calc_required_extents.
   Use proper uint64 casting for calculation of cache metadata size.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c81d354..6304ff6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.88 - 
 =================================
+  Also recognize 'help'/'?' as reserved sort key name to show help.
+  Export recognized DM_REPORT_FIELD_RESERVED_NAME_{HELP,HELP_ALT} to show help.
   Add dm_units_to_factor for size unit parsing.
   Increase bitset size for minors for thin dmeventd plugin.
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 8ffa145..d63b135 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1601,6 +1601,10 @@ struct dm_report_field;
 #define DM_REPORT_FIELD_TYPE_ID_LEN 32
 #define DM_REPORT_FIELD_TYPE_HEADING_LEN 32
 
+/* Reserved field names for special purposes. */
+#define DM_REPORT_FIELD_RESERVED_NAME_HELP "help"  /* shows help */
+#define DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT "?" /* shows help */
+
 struct dm_report;
 struct dm_report_field_type {
 	uint32_t type;		/* object type id */
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 7e8484e..f3395a7 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -529,7 +529,8 @@ static int _parse_fields(struct dm_report *rh, const char *format,
 		if (!_field_match(rh, ws, (size_t) (we - ws), report_type_only)) {
 			_display_fields(rh);
 			log_warn(" ");
-			if (strcasecmp(ws, "help") && strcmp(ws, "?"))
+			if (strcasecmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP) &&
+			    strcmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT))
 				log_error("Unrecognised field: %.*s",
 					  (int) (we - ws), ws);
 			return 0;
@@ -556,8 +557,12 @@ static int _parse_keys(struct dm_report *rh, const char *keys,
 		while (*we && *we != ',')
 			we++;
 		if (!_key_match(rh, ws, (size_t) (we - ws), report_type_only)) {
-			log_error("dm_report: Unrecognised field: %.*s",
-				  (int) (we - ws), ws);
+			_display_fields(rh);
+			log_warn(" ");
+			if (strcasecmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP) &&
+			    strcmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT))
+				log_error("dm_report: Unrecognised field: %.*s",
+					  (int) (we - ws), ws);
 			return 0;
 		}
 	}
diff --git a/tools/reporter.c b/tools/reporter.c
index 2591fd5..b4a0c0b 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -370,7 +370,10 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 					  separator, aligned, buffered,
 					  headings, field_prefixes, quoted,
 					  columns_as_rows))) {
-		if (!strcasecmp(options, "help") || !strcmp(options, "?"))
+		if ( (!strcasecmp(options, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
+		      !strcmp(options, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) ||
+		     (!strcasecmp(keys, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
+		      !strcmp(keys, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) )
 			return r;
 		return_ECMD_FAILED;
 	}


