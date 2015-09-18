From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Sep 2015 15:45:55 +0000 (UTC)
Subject: master - dmsetup: improve help text
Message-ID: <20150918154555.7C08F606FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9c8cefd068194f10639d728e2e73a5cb93c1cbe
Commit:        f9c8cefd068194f10639d728e2e73a5cb93c1cbe
Parent:        791e76ff700304da574ce03e9762c880cd17e522
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 14:37:50 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 17:45:45 2015 +0200

dmsetup: improve help text

Document more options.
---
 WHATS_NEW_DM    |    1 +
 tools/dmsetup.c |   35 +++++++++++++++++++----------------
 2 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3669b85..d69478c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.109 - 
 ======================================
+  Improve help text for dmsetup.
   Use --noflush and --nolockfs when removing device with --force.
   Parse new Overflow status string for snapshot target.
   Check dir path components are valid if using dm_create_dir, error out if not.
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 632c4ca..036f58c 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5110,21 +5110,24 @@ static struct command _dmsetup_commands[] = {
 	{"create", "<dev_name>\n"
 	  "\t    [-j|--major <major> -m|--minor <minor>]\n"
 	  "\t    [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
-	  "\t    [-u|uuid <uuid>] [{--addnodeonresume|--addnodeoncreate}]\n"
-	  "\t    [--notable | --table <table> | <table_file>]", 1, 2, 0, 0, _create},
-	{"remove", "[-f|--force] [--deferred] <device>", 0, -1, 1, 0, _remove},
+	  "\t    [-u|uuid <uuid>] [--addnodeonresume|--addnodeoncreate]\n"
+	  "\t    [--readahead {[+]<sectors>|auto|none}]\n"
+	  "\t    [-n|--notable|--table {<table>|<table_file>}]", 1, 2, 0, 0, _create},
+	{"remove", "[--deferred] [-f|--force] [--retry] <device>", 0, -1, 1, 0, _remove},
 	{"remove_all", "[-f|--force]", 0, 0, 0, 0, _remove_all},
-	{"suspend", "[--noflush] <device>", 0, -1, 1, 0, _suspend},
-	{"resume", "<device> [{--addnodeonresume|--addnodeoncreate}]", 0, -1, 1, 0, _resume},
-	{"load", "<device> [<table_file>]", 0, 2, 0, 0, _load},
+	{"suspend", "[--noflush] [--nolockfs] <device>", 0, -1, 1, 0, _suspend},
+	{"resume", "[--noflush] [--nolockfs] <device>\n"
+	  "\t       [--addnodeonresume|--addnodeoncreate]\n"
+	  "\t       [--readahead {[+]<sectors>|auto|none}]", 0, -1, 1, 0, _resume},
+	  {"load", "<device> [<table>|<table_file>]", 0, 2, 0, 0, _load},
 	{"clear", "<device>", 0, -1, 1, 0, _clear},
-	{"reload", "<device> [<table_file>]", 0, 2, 0, 0, _load},
-	{"wipe_table", "<device>", 1, -1, 1, 0, _error_device},
+	{"reload", "<device> [<table>|<table_file>]", 0, 2, 0, 0, _load},
+	{"wipe_table", "[-f|--force] [--noflush] [--nolockfs] <device>", 1, -1, 1, 0, _error_device},
 	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, 0, _rename},
 	{"message", "<device> <sector> <message>", 2, -1, 0, 0, _message},
-	{"ls", "[--target <target_type>] [--exec <command>] [-o options] [--tree]", 0, 0, 0, 0, _ls},
+	{"ls", "[--target <target_type>] [--exec <command>] [-o <options>] [--tree]", 0, 0, 0, 0, _ls},
 	{"info", "[<device>]", 0, -1, 1, 0, _info},
-	{"deps", "[-o options] [<device>]", 0, -1, 1, 0, _deps},
+	{"deps", "[-o <options>] [<device>]", 0, -1, 1, 0, _deps},
 	{"stats", "<command> [<options>] [<devices>]", 1, -1, 1, 1, _stats},
 	{"status", "[<device>] [--noflush] [--target <target_type>]", 0, -1, 1, 0, _status},
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, 0, _status},
@@ -5135,7 +5138,7 @@ static struct command _dmsetup_commands[] = {
 	{"udevreleasecookie", "[<cookie>]", 0, 1, 0, 0, _udevreleasecookie},
 	{"udevflags", "<cookie>", 1, 1, 0, 0, _udevflags},
 	{"udevcomplete", "<cookie>", 1, 1, 0, 0, _udevcomplete},
-	{"udevcomplete_all", "<age_in_minutes>", 0, 1, 0, 0, _udevcomplete_all},
+	{"udevcomplete_all", "[<age_in_minutes>]", 0, 1, 0, 0, _udevcomplete_all},
 	{"udevcookies", "", 0, 0, 0, 0, _udevcookies},
 	{"targets", "", 0, 0, 0, 0, _targets},
 	{"version", "", 0, 0, 0, 0, _version},
@@ -5185,11 +5188,11 @@ static void _dmsetup_usage(FILE *out)
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "%s\n"
 		"        [--version] [-h|--help [-c|-C|--columns]]\n"
-		"        [-v|--verbose [-v|--verbose ...]]\n"
-		"        [--checks] [--manglename <mangling_mode>]\n"
-		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
-		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
-		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
+		"        [-v|--verbose [-v|--verbose ...]] [-f|--force]\n"
+		"        [--checks] [--manglename {none|hex|auto}]\n"
+		"        [-r|--readonly] [--noopencount] [--noflush] [--nolockfs] [--inactive]\n"
+		"        [--udevcookie <cookie>] [--noudevrules] [--noudevsync] [--verifyudev]\n"
+		"        [-y|--yes] [--readahead {[+]<sectors>|auto|none}] [--retry]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [-S|--select <selection>] [--nameprefixes] [--noheadings]\n"
 		"        [--separator <separator>]\n\n",


