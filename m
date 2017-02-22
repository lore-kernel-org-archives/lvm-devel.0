From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 22 Feb 2017 23:01:20 +0000 (UTC)
Subject: master - man/help: improve the style of units indicator
Message-ID: <20170222230120.ADD3660575@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f4ecaf8c2b3146e81bcb32bd4f0321beee1192a
Commit:        3f4ecaf8c2b3146e81bcb32bd4f0321beee1192a
Parent:        da634bfc8933619a70284077b499c82802f04ceb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 22 16:50:30 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 22 16:50:30 2017 -0600

man/help: improve the style of units indicator

We use --foo Number[k|Units] to indicate that
the default units of the number is k, but other
units listed below are also accepted.

Capitalize and underline Units so it is consistent
with other variables, and reference it at the end.

Technically, the k should be bold, but this
tends to make the text visually hard to read
because of the excessive highlights scattered
everywhere.  So it's left normal text for now
(it's unlikely to confuse anyone.)
---
 tools/command.c |   19 +++++++++----------
 tools/vals.h    |   12 ++++++------
 2 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 1a5fbb5..c3c1960 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1786,20 +1786,19 @@ static void print_val_man(const char *str)
 	int i;
 
 	/*
-	 * The suffix [k|unit] is just printed in plain text.
-	 * Doing bold k and underlined unit creates a lot of
-	 * visual "noise" that is choppy and hard to read.
+	 * Doing bold k before underlined Unit creates a lot of
+	 * visual "noise" that makes the text hard to read.
 	 * The extra markup in this case doesn't add anything
 	 * that isn't already obvious.
 	 */
 
-	if (!strcmp(str, "Number[k|unit]")) {
-		printf("\\fINumber\\fP[k|unit]");
+	if (!strcmp(str, "Number[k|Unit]")) {
+		printf("\\fINumber\\fP[k|\\fIUnit\\fP]");
 		return;
 	}
 
-	if (!strcmp(str, "Number[m|unit]")) {
-		printf("\\fINumber\\fP[m|unit]");
+	if (!strcmp(str, "Number[m|Unit]")) {
+		printf("\\fINumber\\fP[m|\\fIUnit\\fP]");
 		return;
 	}
 
@@ -2799,13 +2798,13 @@ void print_man_all_positions_desc(struct command_name *cname)
 	/* Nearly every command uses a number arg somewhere. */
 
 	printf("\n.HP\n");
-	printf("\\fINumber\\fP");
+	printf("\\fINumber\\fP, \\fIUnit\\fP");
 	printf("\n");
 	printf(".br\n");
 	printf("Input units are always treated as base two values, regardless of unit\n"
 	       "capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
-	       "The default input unit is specified by letter, followed by |unit which\n"
-	       "represents other possible input units: bBsSkKmMgGtTpPeE.\n");
+	       "The default input unit is specified by letter, followed by |\\fIUnit\\fP\n"
+	       "which represents other possible input units: \\fBbBsSkKmMgGtTpPeE\\fP.\n");
 
 	printf("\n.HP\n");
 	printf("Environment");
diff --git a/tools/vals.h b/tools/vals.h
index 4dc3a61..3eb27e9 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -83,10 +83,10 @@
  * could be "Number[bBsSkKmMgGtTpPeE]" (with implied |),
  * but repeating this full specification produces cluttered
  * output, and doesn't indicate which unit is the default.
- * "Number[units]" would be cleaner, as would a subset of
+ * "Number[Units]" would be cleaner, as would a subset of
  * common units, e.g. "Number[kmg...]", but neither helps
- * with default.  "Number[k|unit]" and "Number[m|unit]" show
- * the default, and "unit" indicates that other units
+ * with default.  "Number[k|Unit]" and "Number[m|Unit]" show
+ * the default, and "Unit" indicates that other units
  * are possible without listing them all.  This also
  * suggests using the preferred lower case letters, because
  * --size and other option args treat upper/lower letters
@@ -115,9 +115,9 @@ val(activation_VAL, activation_arg, "Active", "y|n|ay")
 val(cachemode_VAL, cachemode_arg, "CacheMode", "writethrough|writeback")
 val(discards_VAL, discards_arg, "Discards", "passdown|nopassdown|ignore")
 val(mirrorlog_VAL, mirrorlog_arg, "MirrorLog", "core|disk")
-val(sizekb_VAL, size_kb_arg, "SizeKB", "Number[k|unit]")
-val(sizemb_VAL, size_mb_arg, "SizeMB", "Number[m|unit]")
-val(regionsize_VAL, regionsize_arg, "RegionSize", "Number[m|unit]")
+val(sizekb_VAL, size_kb_arg, "SizeKB", "Number[k|Unit]")
+val(sizemb_VAL, size_mb_arg, "SizeMB", "Number[m|Unit]")
+val(regionsize_VAL, regionsize_arg, "RegionSize", "Number[m|Unit]")
 val(numsigned_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
 val(numsignedper_VAL, int_arg_with_sign_and_percent, "SNumberP", "[+|-]Number[%VG|%PVS|%FREE]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")


