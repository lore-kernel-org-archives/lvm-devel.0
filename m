From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 19 Feb 2017 23:46:52 +0000 (UTC)
Subject: master - lvresize: fix regressiong on accepting args
Message-ID: <20170219234652.1566B60554@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87c89ac2791e9b443db8c009db67610cbd97b4f2
Commit:        87c89ac2791e9b443db8c009db67610cbd97b4f2
Parent:        13944738d49ee420cb8b6b9eab4984b0a01b700d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 19 19:08:48 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Feb 19 22:59:43 2017 +0100

lvresize: fix regressiong on accepting args

Commit f45b68940667563e1a8d3bbd5d30864c04381bdf caused regression
of lvresize -m and --type  parameter

After fix this sequence may work when we also fix syntax description:

lvcreate -l1 -m1 -n lv1 vg
lvextend --type mirror -m1 -l+1 vg/lv1
---
 tools/lvresize.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 28fd0fd..1d59239 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -21,7 +21,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	const char *cmd_name = command_name(cmd);
 	const char *type_str = arg_str_value(cmd, type_ARG, NULL);
 
-	if (type_str && (lp->segtype = get_segtype_from_string(cmd, type_str)))
+	if (type_str && !(lp->segtype = get_segtype_from_string(cmd, type_str)))
 		return_0;
 
 	if (!strcmp(cmd_name, "lvreduce"))
@@ -122,10 +122,13 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		return 0;
 	}
 
-	if ((lp->mirrors = arg_count(cmd, mirrors_ARG)) &&
-	    (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS)) {
-		log_error("Mirrors argument may not be signed.");
-		return 0;
+	if (arg_is_set(cmd, mirrors_ARG)) {
+		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) != SIGN_NONE) {
+			log_error("Mirrors argument may not be signed.");
+			return 0;
+		}
+		if ((lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0)))
+			lp->mirrors++;
 	}
 
 	if ((lp->stripes = arg_uint_value(cmd, stripes_ARG, 0)) &&


