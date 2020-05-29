From: David Teigland <teigland@sourceware.org>
Date: Fri, 29 May 2020 18:27:34 +0000 (GMT)
Subject: master - Revert "pvck: dump headers_only to skip metadata text"
Message-ID: <20200529182734.7CB02388B031@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d14a8040d4a2b264130cdb730cead935b0bf19f0
Commit:        d14a8040d4a2b264130cdb730cead935b0bf19f0
Parent:        ae029fcced5f79af748df28f20f952d158804482
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 29 13:26:43 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 29 13:26:43 2020 -0500

Revert "pvck: dump headers_only to skip metadata text"

This reverts commit 5410dd5441aa827b381ff64dfc6be6e4589d87a1.

Accidental push.
---
 tools/lvmcmdline.c |  1 -
 tools/pvck.c       | 12 ++----------
 tools/vals.h       |  2 +-
 3 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 608653827..d87a8f053 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1092,7 +1092,6 @@ int repairtype_arg(struct cmd_context *cmd, struct arg_values *av)
 int dumptype_arg(struct cmd_context *cmd, struct arg_values *av)
 {
 	if (!strcmp(av->value, "headers") ||
-	    !strcmp(av->value, "headers_only") ||
 	    !strcmp(av->value, "metadata") ||
 	    !strcmp(av->value, "metadata_all") ||
 	    !strcmp(av->value, "metadata_search") ||
diff --git a/tools/pvck.c b/tools/pvck.c
index cd2c5b6d4..a0f567eeb 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -24,7 +24,6 @@
 
 #define PRINT_CURRENT 1
 #define PRINT_ALL 2
-#define PRINT_NONE 3
 
 #define ID_STR_SIZE 40 /* uuid formatted with dashes is 38 chars */
 
@@ -1389,7 +1388,6 @@ static int _dump_headers(struct cmd_context *cmd, const char *dump, struct setti
 {
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0; /* bytes */
 	uint32_t mda1_checksum, mda2_checksum;
-	int print_metadata = 0;
 	int mda_count = 0;
 	int bad = 0;
 
@@ -1402,17 +1400,14 @@ static int _dump_headers(struct cmd_context *cmd, const char *dump, struct setti
 		return 1;
 	}
 
-	if (!strcmp(dump, "headers_only"))
-		print_metadata = PRINT_NONE;
-
 	/*
 	 * The first mda is always 4096 bytes from the start of the device.
 	 */
-	if (!_dump_mda_header(cmd, set, 1, print_metadata, 0, NULL, dev, def, 4096, mda1_size, &mda1_checksum, NULL))
+	if (!_dump_mda_header(cmd, set, 1, 0, 0, NULL, dev, def, 4096, mda1_size, &mda1_checksum, NULL))
 		bad++;
 
 	if (mda2_offset) {
-		if (!_dump_mda_header(cmd, set, 1, print_metadata, 0, NULL, dev, def, mda2_offset, mda2_size, &mda2_checksum, NULL))
+		if (!_dump_mda_header(cmd, set, 1, 0, 0, NULL, dev, def, mda2_offset, mda2_size, &mda2_checksum, NULL))
 			bad++;
 
 		/* This probably indicates that one was committed and the other not. */
@@ -3088,9 +3083,6 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		else if (!strcmp(dump, "headers"))
 			ret = _dump_headers(cmd, dump, &set, labelsector, dev, def);
 
-		else if (!strcmp(dump, "headers_only"))
-			ret = _dump_headers(cmd, dump, &set, labelsector, dev, def);
-
 		else if (!strcmp(dump, "backup_to_raw")) {
 			ret = _dump_backup_to_raw(cmd, &set);
 
diff --git a/tools/vals.h b/tools/vals.h
index 623859e4d..70404436b 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -142,7 +142,7 @@ val(reportformat_VAL, reportformat_arg, "ReportFmt", "basic|json")
 val(configreport_VAL, configreport_arg, "ConfigReport", "log|vg|lv|pv|pvseg|seg")
 val(configtype_VAL, configtype_arg, "ConfigType", "current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata")
 val(repairtype_VAL, repairtype_arg, "RepairType", "pv_header|metadata|label_header")
-val(dumptype_VAL, dumptype_arg, "DumpType", "headers|headers_only|metadata|metadata_all|metadata_search")
+val(dumptype_VAL, dumptype_arg, "DumpType", "headers|metadata|metadata_all|metadata_search")
 
 /* this should always be last */
 val(VAL_COUNT, NULL, NULL, NULL)


