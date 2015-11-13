From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:02 +0000 (UTC)
Subject: master - reporter: add missing stack trace
Message-ID: <20151113101902.827F5610A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0128770d6d881c7f30fc5e22137d1b20ce003e13
Commit:        0128770d6d881c7f30fc5e22137d1b20ce003e13
Parent:        43777b551d840a55d70e862bff751e7208c8eaf4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 11 22:07:39 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:17:05 2015 +0100

reporter: add missing stack trace

Use goto_out on error paths.
---
 tools/reporter.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 2c733e3..71f20a3 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -657,9 +657,8 @@ static int _get_report_options(struct cmd_context *cmd,
 	int r = ECMD_PROCESSED;
 
 	if (!(mem = dm_pool_create("report_options", 128))) {
-		r = ECMD_FAILED;
 		log_error("Failed to create temporary mempool to process report options.");
-		goto_out;
+		return ECMD_FAILED;
 	}
 
 	if (!(final_opts_list = str_to_str_list(mem, *options, ",", 1))) {
@@ -704,24 +703,24 @@ static int _get_report_options(struct cmd_context *cmd,
 			default:
 				if (!(final_opts_list = str_to_str_list(mem, opts, ",", 1))) {
 					r = ECMD_FAILED;
-					goto out;
+					goto_out;
 				}
 		}
 	}
 
 	if (!(*options = str_list_to_str(cmd->mem, final_opts_list, ","))) {
 		r = ECMD_FAILED;
-		goto out;
+		goto_out;
 	}
 	if (final_compact_list &&
 	    !(*fields_to_compact = str_list_to_str(cmd->mem, final_compact_list, ","))) {
 		dm_pool_free(cmd->mem, (char *) *options);
 		r = ECMD_FAILED;
-		goto out;
+		goto_out;
 	}
 out:
-	if (mem)
-		dm_pool_destroy(mem);
+	dm_pool_destroy(mem);
+
 	return r;
 }
 


