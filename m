From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 May 2020 14:03:22 +0000 (GMT)
Subject: master - pvck: set dump on one call
Message-ID: <20200520140322.42CDA395CC54@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=16da6651a1eebd776aa461db76cecaf3997cbf50
Commit:        16da6651a1eebd776aa461db76cecaf3997cbf50
Parent:        cf74123830250984743d28687e66a0954510b4fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 15 15:05:39 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 20 15:55:39 2020 +0200

pvck: set dump on one call

arg_str_value() has built-in  arg_is_set().

Also this makes it obvious to coverity 'dump != NULL' & 'repair != NULL'
at the branch code path.
---
 tools/pvck.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 71bfc1b63..a0f567eeb 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -3065,11 +3065,9 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 
 	label_scan_setup_bcache();
 
-	if (arg_is_set(cmd, dump_ARG)) {
+	if ((dump = arg_str_value(cmd, dump_ARG, NULL))) {
 		cmd->use_hints = 0;
 
-		dump = arg_str_value(cmd, dump_ARG, NULL);
-
 		if (!strcmp(dump, "metadata"))
 			ret = _dump_metadata(cmd, dump, &set, labelsector, dev, def, PRINT_CURRENT, 0);
 
@@ -3096,11 +3094,9 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_PROCESSED;
 	}
 
-	if (arg_is_set(cmd, repairtype_ARG)) {
+	if ((repair = arg_str_value(cmd, repairtype_ARG, NULL))) {
 		cmd->use_hints = 0;
 
-		repair = arg_str_value(cmd, repairtype_ARG, NULL);
-
 		if (!strcmp(repair, "label_header"))
 			ret = _repair_label_header(cmd, repair, &set, labelsector, dev);
 


