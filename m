From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Sep 2017 12:11:32 -0400
Subject: master - improve error messages when command rules fail
Message-ID: <201709201611.v8KGBW6q011703@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ab9e4b6a720972cffc8bc465f4d4c3d788d0820
Commit:        0ab9e4b6a720972cffc8bc465f4d4c3d788d0820
Parent:        f2ee0e7aca6020cf273f22dc5bca20bfa3c89051
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 20 10:51:52 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 20 11:10:35 2017 -0500

improve error messages when command rules fail

When certain cmd def RULE's fail, the error messages can
sometimes be confusing.  This expands the error messages
to help clarify why the rule failed, especially in cases
where options are used incorrectly.
---
 tools/command-lines.in |    2 +-
 tools/toollib.c        |   34 +++++++++++++++++++++++++---------
 2 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index ec02fa4..265bda8 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -677,7 +677,7 @@ DESC: Replace failed PVs in a raid or mirror LV.
 DESC: Repair a thin pool.
 DESC: Repair a cache pool.
 RULE: all not lv_is_locked lv_is_pvmove
-RULE: --poolmetadataspare Bool and LV_cache LV_cachepool LV_thinpool
+RULE: --poolmetadataspare and LV_cache LV_cachepool LV_thinpool
 
 lvconvert --replace PV LV_raid
 OO: OO_LVCONVERT
diff --git a/tools/toollib.c b/tools/toollib.c
index bf3e9d6..b28167b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2819,7 +2819,7 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 		if (rule->check_opts && (rule->rule == RULE_INVALID) && opts_match_count) {
 			memset(buf, 0, sizeof(buf));
 			opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, buf, sizeof(buf));
-			log_warn("Command on LV %s does not accept option %s.",
+			log_warn("Command on LV %s has invalid use of option %s.",
 				 display_lvname(lv), buf);
 			ret = 0;
 		}
@@ -2837,8 +2837,12 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 		/* Fail if the LV matches any of the invalid LV types. */
 
 		if (rule->check_lvt_bits && (rule->rule == RULE_INVALID) && lv_types_match_bits) {
-			log_warn("Command on LV %s does not accept LV type %s.",
-				 display_lvname(lv), lvtype ? lvtype->name : "unknown");
+			if (rule->opts_count)
+				log_warn("Command on LV %s uses options invalid with LV type %s.",
+				 	 display_lvname(lv), lvtype ? lvtype->name : "unknown");
+			else
+				log_warn("Command on LV %s with invalid LV type %s.",
+				 	 display_lvname(lv), lvtype ? lvtype->name : "unknown");
 			ret = 0;
 		}
 
@@ -2847,8 +2851,12 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 		if (rule->check_lvt_bits && (rule->rule == RULE_REQUIRE) && !lv_types_match_bits) {
 			memset(buf, 0, sizeof(buf));
 			lvt_bits_to_str(rule->check_lvt_bits, buf, sizeof(buf));
-			log_warn("Command on LV %s does not accept LV type %s. Required LV types are %s.",
-				 display_lvname(lv), lvtype ? lvtype->name : "unknown", buf);
+			if (rule->opts_count)
+				log_warn("Command on LV %s uses options that require LV types %s.",
+					 display_lvname(lv), buf);
+			else
+				log_warn("Command on LV %s does not accept LV type %s. Required LV types are %s.",
+					 display_lvname(lv), lvtype ? lvtype->name : "unknown", buf);
 			ret = 0;
 		}
 
@@ -2857,8 +2865,12 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 		if (rule->check_lvp_bits && (rule->rule == RULE_INVALID) && lv_props_match_bits) {
 			memset(buf, 0, sizeof(buf));
 			lvp_bits_to_str(lv_props_match_bits, buf, sizeof(buf));
-			log_warn("Command on LV %s does not accept LV with properties: %s.",
-				 display_lvname(lv), buf);
+			if (rule->opts_count)
+				log_warn("Command on LV %s uses options that are invalid with LV properties: %s.",
+				 	 display_lvname(lv), buf);
+			else
+				log_warn("Command on LV %s is invalid on LV with properties: %s.",
+				 	 display_lvname(lv), buf);
 			ret = 0;
 		}
 
@@ -2867,8 +2879,12 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 		if (rule->check_lvp_bits && (rule->rule == RULE_REQUIRE) && lv_props_unmatch_bits) {
 			memset(buf, 0, sizeof(buf));
 			lvp_bits_to_str(lv_props_unmatch_bits, buf, sizeof(buf));
-			log_warn("Command on LV %s requires LV with properties: %s.",
-				 display_lvname(lv), buf);
+			if (rule->opts_count)
+				log_warn("Command on LV %s uses options that require LV properties: %s.",
+				 	 display_lvname(lv), buf);
+			else
+				log_warn("Command on LV %s requires LV with properties: %s.",
+				 	 display_lvname(lv), buf);
 			ret = 0;
 		}
 	}


