From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Apr 2014 00:42:00 +0000 (UTC)
Subject: master - reports: FIXME for unnecessary cache wipes.
Message-ID: <20140404004200.1CE5360D8E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d36f721bb984c16bd20733325be0d9fc73706709
Commit:        d36f721bb984c16bd20733325be0d9fc73706709
Parent:        3f0f5587864e8bb0457089d1cca50b2231b421de
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 4 01:41:06 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 4 01:41:06 2014 +0100

reports: FIXME for unnecessary cache wipes.

---
 tools/reporter.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index e070bc2..2591fd5 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -271,6 +271,9 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			report_type == LABEL ||
 			report_type == PVSEGS) ? 1 : 0;
 
+	/*
+	 * FIXME Trigger scans based on unrecognised listed devices instead.
+	 */
 	if (args_are_pvs && argc)
 		cmd->filter->wipe(cmd->filter);
 


