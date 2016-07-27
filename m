From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 Jul 2016 14:21:34 +0000 (UTC)
Subject: master - lvconvert: tune cache-pool zeroing
Message-ID: <20160727142134.00F6C60AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c377f8334491421207ae91094e9d7b3be0a300f
Commit:        3c377f8334491421207ae91094e9d7b3be0a300f
Parent:        5636bfd83d54f119d313603f4f9070bf0dfba2fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 23 21:17:56 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 27 16:20:57 2016 +0200

lvconvert: tune cache-pool zeroing

Follow-up to 27a767d5e8cedf9cac31eb3562cf8fdd4aa88b7c.
Tunning behavior in a way we always prompt when option --zero is NOT specified.
Without -Z lvm expects user wants to 'reset' cache-pool metadata
(they could have been splitted from some cached LV)

If user doesn't want to zero metadata he needs to specify -Zn.

User may also avoid prompting for zeroing by using -Zy for
cache-pool (basically equals using --yes  without -Z being given)
(unlike full convert case, there is no cache-pool being converted,
so there is not 'uncoditional' prompt in this case).
---
 WHATS_NEW         |    2 +-
 tools/lvconvert.c |   28 ++++++++++++++++------------
 2 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index abd9fb8..5c09a1f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -5,7 +5,7 @@ Version 2.02.162 -
   Improve lvconvert --trackchanges validation to require --splitmirrors 1.
   Add note about lastlog built-in command to lvm man page.
   Fix unrecognised segtype flag message.
-  lvconvert reuse cachepool metadade now ONLY with -Zn and clear otherwise.
+  lvconvert not clears cache pool metadata ONLY with -Zn.
   Enabled lvconvert --uncache to work with partial VG.
 
 Version 2.02.161 - 15th July 2016
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index be7425f..f3586b2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2998,24 +2998,28 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 				return_0;
 
 			if (lp->cache) {
-				/* Check is user has not requested -Zn */
-				if (!arg_int_value(cmd, zero_ARG, 1)) {
-					/* Note: requires rather deep know-how to skip zeroing
-					 * so show major warnings */
-					log_warn("WARNING: Reusing old cache pool metadata %s to "
-						 "for volume caching.",
-						 display_lvname(pool_lv));
-					log_warn("THIS MAY DESTROY YOUR DATA (filesystem etc.)");
-
+				/* Check is user requested zeroing logic via [-Z y|n] */
+				if (!arg_is_set(cmd, zero_ARG)) {
+					/* Note: requires rather deep know-how to skip zeroing */
 					if (!lp->yes &&
-					    yes_no_prompt("Do you really want to keep old metadata for "
+					    yes_no_prompt("Do you want wipe existing metadata of "
 							  "cache pool volume %s? [y/n]: ",
 							  display_lvname(pool_lv)) == 'n') {
 						log_error("Conversion aborted.");
+						log_error("To preserve cache metadata add option \"--zero n\".");
+						log_warn("WARNING: Reusing mismatched cache pool metadata "
+							 "MAY DESTROY YOUR DATA!");
 						return 0;
 					}
-				} else if (!wipe_cache_pool(pool_lv))
-					return_0;
+					/* Wiping confirmed, go ahead */
+					if (!wipe_cache_pool(pool_lv))
+						return_0;
+				} else if (arg_int_value(cmd, zero_ARG, 0)) {
+					if (!wipe_cache_pool(pool_lv)) /* Wipe according to -Z y|n */
+						return_0;
+				} else
+					log_warn("WARNING: Reusing cache pool metadata %s "
+						 "for volume caching.", display_lvname(pool_lv));
 			}
 
 			if (lp->thin || lp->cache)


