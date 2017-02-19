From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 19 Feb 2017 23:47:04 +0000 (UTC)
Subject: master - cleanup: use multiline string
Message-ID: <20170219234704.9D49A60563@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8514b24e115f4c45fb7b6263f553a30e776a3da
Commit:        d8514b24e115f4c45fb7b6263f553a30e776a3da
Parent:        aff62c74b7b947d19dda7f03e79d0f2437ad4730
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 18 19:09:24 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 20 00:43:40 2017 +0100

cleanup: use multiline string

---
 tools/lvmcmdline.c |   50 +++++++++++++++++++++++++-------------------------
 1 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e796873..9fa8d94 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1684,30 +1684,30 @@ static void _usage_notes(void)
 	 * [ ] for optional, ... for repeatable, | for one of the following,
 	 * -- for an option name, lower case strings and digits for literals.
 	 */
-	log_print("Usage notes:");
-	log_print(". Variable parameters are: Number, String, PV, VG, LV, Tag.");
-	log_print(". Select indicates that a required positional parameter can");
-	log_print("  be omitted if the --select option is used.");
-	log_print(". --size Number can be replaced with --extents NumberExtents.");
-	log_print(". When --name is omitted from lvcreate, a new LV name is");
-	log_print("  generated with the \"lvol\" prefix and a unique numeric suffix.");
-	log_print(". The required VG parameter in lvcreate may be omitted when");
-	log_print("  the VG name is included in another option, e.g. --name VG/LV.");
-	log_print(". For required options listed in parentheses, e.g. (--A, --B),");
-	log_print("  any one is required, after which the others are optional.");
-	log_print(". The _new suffix indicates the VG or LV must not yet exist.");
-	log_print(". LV followed by _<type> indicates that an LV of the given type");
-	log_print("  is required.  (raid represents any raid<N> type.)");
-	log_print(". Input units are always treated as base two values, regardless of");
-	log_print("  unit capitalization, e.g. 'k' and 'K' both refer to 1024.");
-	log_print(". The default input unit is specified by letter, followed by |unit");
-	log_print("  which represents other possible input units: bBsSkKmMgGtTpPeE.");
-	log_print(". Output units can be specified with the --units option, for which");
-	log_print("  lower/upper case letters refer to base 2/10 values.");
-	log_print("  formats that are recognized, e.g. for compatibility.");
-	log_print(". See man pages for short option equivalents of long option names,");
-	log_print("  and for more detailed descriptions of variable parameters.");
-	log_print(" ");
+	log_print("Usage notes:\n"
+		  ". Variable parameters are: Number, String, PV, VG, LV, Tag.\n"
+		  ". Select indicates that a required positional parameter can\n"
+		  "  be omitted if the --select option is used.\n"
+		  ". --size Number can be replaced with --extents NumberExtents.\n"
+		  ". When --name is omitted from lvcreate, a new LV name is\n"
+		  "  generated with the \"lvol\" prefix and a unique numeric suffix.\n"
+		  ". The required VG parameter in lvcreate may be omitted when\n"
+		  "  the VG name is included in another option, e.g. --name VG/LV.\n"
+		  ". For required options listed in parentheses, e.g. (--A, --B),\n"
+		  "  any one is required, after which the others are optional.\n"
+		  ". The _new suffix indicates the VG or LV must not yet exist.\n"
+		  ". LV followed by _<type> indicates that an LV of the given type\n"
+		  "  is required.  (raid represents any raid<N> type.)\n"
+		  ". Input units are always treated as base two values, regardless of\n"
+		  "  unit capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
+		  ". The default input unit is specified by letter, followed by |unit\n"
+		  "  which represents other possible input units: bBsSkKmMgGtTpPeE.\n"
+		  ". Output units can be specified with the --units option, for which\n"
+		  "  lower/upper case letters refer to base 2/10 values.\n"
+		  "  formats that are recognized, e.g. for compatibility.\n"
+		  ". See man pages for short option equivalents of long option names,\n"
+		  "  and for more detailed descriptions of variable parameters.\n"
+		  "  \n");
 }
 
 static int _usage(const char *name, int longhelp)
@@ -3285,6 +3285,6 @@ int lvm2_main(int argc, char **argv)
 
       out:
 	lvm_fin(cmd);
+
 	return lvm_return_code(ret);
 }
-


