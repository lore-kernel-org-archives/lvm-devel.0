From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Oct 2016 11:39:26 +0000 (UTC)
Subject: master - lvconvert: use _read_conversion_type
Message-ID: <20161011113926.0113C6027B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=706d3ddf901584d182b5bab49f3d7d4b3476e807
Commit:        706d3ddf901584d182b5bab49f3d7d4b3476e807
Parent:        1186cf2ad4bbfef07ead644dc689745d10709789
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 11 13:19:12 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 11 13:36:51 2016 +0200

lvconvert: use _read_conversion_type

Code reodering and using same pattern for reading and validating arg
(--type in this case).
---
 tools/lvconvert.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a5ef234..05bf51a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -314,9 +314,14 @@ static int _striped_type_requested(const char *type_str)
 	return (!strcmp(type_str, SEG_TYPE_NAME_STRIPED) || _linear_type_requested(type_str));
 }
 
-static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
+static int _read_conversion_type(struct cmd_context *cmd,
+				 struct lvconvert_params *lp)
 {
-	if (!type_str || !*type_str)
+
+	const char *type_str = arg_str_value(cmd, type_ARG, "");
+
+	lp->type_str =  type_str;
+	if (!lp->type_str[0])
 		return 1;
 
 	/* FIXME: Check thin-pool and thin more thoroughly! */
@@ -443,9 +448,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	int region_size;
 	int pagesize = lvm_getpagesize();
 
-	lp->type_str = arg_str_value(cmd, type_ARG, "");
-
-	if (*lp->type_str && !_check_conversion_type(cmd, lp->type_str))
+	if (!_read_conversion_type(cmd, lp))
 		return_0;
 
 	/* If --repair, check for incompatible args. */


