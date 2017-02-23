From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 23 Feb 2017 20:28:23 +0000 (UTC)
Subject: master - man/help: change syntax to UNIT
Message-ID: <20170223202823.182826108C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3fd3c9430d5f0b3291c0111ddcd4ddd524dd26ed
Commit:        3fd3c9430d5f0b3291c0111ddcd4ddd524dd26ed
Parent:        8ab072507706fb826eee05eb369429ad0a7a406a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 23 14:24:28 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 23 14:24:28 2017 -0600

man/help: change syntax to UNIT

(Change to recent commit 3f4ecaf8c2.)

Use --foo Number[k|UNIT] to indicate that
the default units of the number is k, but other
units listed below are also accepted.

Previously, underlined/italic Unit was used,
like other of variables, but this UNIT is more
like a shortcut than an actual variable.
---
 tools/command.c |   18 ++++++++++--------
 tools/vals.h    |   10 +++++-----
 2 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index c3c1960..04b44ad 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1786,19 +1786,19 @@ static void print_val_man(const char *str)
 	int i;
 
 	/*
-	 * Doing bold k before underlined Unit creates a lot of
+	 * Doing bold k before UNIT creates a lot of
 	 * visual "noise" that makes the text hard to read.
 	 * The extra markup in this case doesn't add anything
 	 * that isn't already obvious.
 	 */
 
-	if (!strcmp(str, "Number[k|Unit]")) {
-		printf("\\fINumber\\fP[k|\\fIUnit\\fP]");
+	if (!strcmp(str, "Number[k|UNIT]")) {
+		printf("\\fINumber\\fP[k|UNIT]");
 		return;
 	}
 
-	if (!strcmp(str, "Number[m|Unit]")) {
-		printf("\\fINumber\\fP[m|\\fIUnit\\fP]");
+	if (!strcmp(str, "Number[m|UNIT]")) {
+		printf("\\fINumber\\fP[m|UNIT]");
 		return;
 	}
 
@@ -2798,13 +2798,15 @@ void print_man_all_positions_desc(struct command_name *cname)
 	/* Nearly every command uses a number arg somewhere. */
 
 	printf("\n.HP\n");
-	printf("\\fINumber\\fP, \\fIUnit\\fP");
+	printf("\\fINumber\\fP, UNIT");
 	printf("\n");
 	printf(".br\n");
 	printf("Input units are always treated as base two values, regardless of unit\n"
 	       "capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
-	       "The default input unit is specified by letter, followed by |\\fIUnit\\fP\n"
-	       "which represents other possible input units: \\fBbBsSkKmMgGtTpPeE\\fP.\n");
+	       "The default input unit is specified by letter, followed by |UNIT\n"
+	       "which represents other possible input units: \\fBbBsSkKmMgGtTpPeE\\fP.\n"
+	       "(This should not be confused with the output control --units, where\n"
+	       "capital letters mean multiple of 1000.)\n");
 
 	printf("\n.HP\n");
 	printf("Environment");
diff --git a/tools/vals.h b/tools/vals.h
index 3eb27e9..a94f81b 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -85,8 +85,8 @@
  * output, and doesn't indicate which unit is the default.
  * "Number[Units]" would be cleaner, as would a subset of
  * common units, e.g. "Number[kmg...]", but neither helps
- * with default.  "Number[k|Unit]" and "Number[m|Unit]" show
- * the default, and "Unit" indicates that other units
+ * with default.  "Number[k|UNIT]" and "Number[m|UNIT]" show
+ * the default, and "UNIT" indicates that other units
  * are possible without listing them all.  This also
  * suggests using the preferred lower case letters, because
  * --size and other option args treat upper/lower letters
@@ -115,9 +115,9 @@ val(activation_VAL, activation_arg, "Active", "y|n|ay")
 val(cachemode_VAL, cachemode_arg, "CacheMode", "writethrough|writeback")
 val(discards_VAL, discards_arg, "Discards", "passdown|nopassdown|ignore")
 val(mirrorlog_VAL, mirrorlog_arg, "MirrorLog", "core|disk")
-val(sizekb_VAL, size_kb_arg, "SizeKB", "Number[k|Unit]")
-val(sizemb_VAL, size_mb_arg, "SizeMB", "Number[m|Unit]")
-val(regionsize_VAL, regionsize_arg, "RegionSize", "Number[m|Unit]")
+val(sizekb_VAL, size_kb_arg, "SizeKB", "Number[k|UNIT]")
+val(sizemb_VAL, size_mb_arg, "SizeMB", "Number[m|UNIT]")
+val(regionsize_VAL, regionsize_arg, "RegionSize", "Number[m|UNIT]")
 val(numsigned_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
 val(numsignedper_VAL, int_arg_with_sign_and_percent, "SNumberP", "[+|-]Number[%VG|%PVS|%FREE]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")


