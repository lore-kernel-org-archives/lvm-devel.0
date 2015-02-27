From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 27 Feb 2015 12:47:31 +0000 (UTC)
Subject: master - report: one more comment explaining change of report type when tags are used for original LABEL reporting
Message-ID: <20150227124731.A02356109C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b154ae4a3d875009aa7a7d081c8e76cdb6dd50f
Commit:        5b154ae4a3d875009aa7a7d081c8e76cdb6dd50f
Parent:        9ea77b788b0822fe06e8efb92d13f80dbc62e351
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 27 13:48:47 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 27 13:48:47 2015 +0100

report: one more comment explaining change of report type when tags are used for original LABEL reporting

---
 tools/reporter.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index df5a58b..0e563ac 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -585,6 +585,10 @@ static void _check_pv_list(struct cmd_context *cmd, int argc, char **argv,
 				rescan_done = 1;
 			}
 			if (*argv[i] == '@') {
+				/*
+				 * Tags are metadata related, not label
+				 * related, change report type accordingly!
+				 */
 				if (*report_type == LABEL)
 					*report_type = PVS;
 				/*


