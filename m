From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 19 Jun 2014 14:17:55 +0000 (UTC)
Subject: master - libdevmapper: revoke commit 7c86131233011c9fb81190bcb40d5d4ac54a533d
Message-ID: <20140619141755.D4B1E60B5C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a40bc36b2e360ad357820e6de2f5ec9fa64a6772
Commit:        a40bc36b2e360ad357820e6de2f5ec9fa64a6772
Parent:        cd7325f18d6869452447b7e1d08d8ada7703e0de
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 19 15:47:24 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 19 16:09:32 2014 +0200

libdevmapper: revoke commit 7c86131233011c9fb81190bcb40d5d4ac54a533d

We have "help" and "?" defined as implicit fields now. As such, we
don't need to export these names in libdevmapper (as it was introduced
by commit 7c86131233011c9fb81190bcb40d5d4ac54a533d within this release).
If anyone uses these field names by mistake, the libdevmapper code can
error out correctly if it detects that the set of explicit field names
(the ones supplied by "fields" arg in dm_report_init/dm_report_init_with_selection)
contains any of the implicit field names (the ones defined internally
by libdevmapper itself).
---
 WHATS_NEW_DM         |    1 -
 libdm/libdevmapper.h |    4 ----
 libdm/libdm-report.c |    8 ++++----
 3 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3d1eee1..119016a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -19,7 +19,6 @@ Version 1.02.88 -
   Document env var 'DM_DEFAULT_NAME_MANGLING_MODE' in dmsetup man page.
   Warn user about incorrect use of cookie with 'dmsetup remove --force'.
   Also recognize 'help'/'?' as reserved sort key name to show help.
-  Export recognized DM_REPORT_FIELD_RESERVED_NAME_{HELP,HELP_ALT} to show help.
   Add dm_units_to_factor for size unit parsing.
   Increase bitset size for minors for thin dmeventd plugin.
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index fab1071..90e0b51 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1642,10 +1642,6 @@ struct dm_report_field;
 #define DM_REPORT_FIELD_TYPE_ID_LEN 32
 #define DM_REPORT_FIELD_TYPE_HEADING_LEN 32
 
-/* Reserved field names for special purposes. */
-#define DM_REPORT_FIELD_RESERVED_NAME_HELP "help"  /* shows help */
-#define DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT "?" /* shows help */
-
 struct dm_report;
 struct dm_report_field_type {
 	uint32_t type;		/* object type id */
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 8e46f78..012dca4 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -194,8 +194,8 @@ struct row {
  */
 #define COMMON_REPORT_TYPE 0x80000000
 #define COMMON_FIELD_SELECTED_ID "selected"
-#define COMMON_FIELD_HELP_ID DM_REPORT_FIELD_RESERVED_NAME_HELP
-#define COMMON_FIELD_HELP_ALT_ID DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT
+#define COMMON_FIELD_HELP_ID "help"
+#define COMMON_FIELD_HELP_ALT_ID "?"
 
 static void *_null_returning_fn(void *obj __attribute__((unused)))
 {
@@ -2663,8 +2663,8 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 	}
 	rh->reserved_values = reserved_values;
 
-	if (!strcasecmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
-	    !strcmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) {
+	if (!strcasecmp(selection, COMMON_FIELD_HELP_ID) ||
+	    !strcmp(selection, COMMON_FIELD_HELP_ALT_ID)) {
 		_display_fields(rh, 0, 1);
 		log_warn(" ");
 		_display_selection_help(rh);


