From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:12:46 +0000 (UTC)
Subject: master - cleanup: make report type condition consistent with the rest of the code
Message-ID: <20150210151246.87B786108E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a19866a74c5101d262586ad0e08317e9a514977
Commit:        2a19866a74c5101d262586ad0e08317e9a514977
Parent:        455ef6f2f58e5af11a75eb4b369c1a48780b068d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Nov 25 14:13:04 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:05:23 2015 +0100

cleanup: make report type condition consistent with the rest of the code

It's just more readable this way (each condition resulting in a certain
report type is always on one line), just like it's used elsewhere in the
code.
---
 tools/reporter.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 20fa4ab..7517ac5 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -543,9 +543,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	if ((report_type & PVSEGS) ||
 	    ((report_type & (PVS | LABEL)) && (report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS))))
 		report_type = PVSEGS;
-	else if ((report_type & LABEL) && (report_type & VGS))
-		report_type = PVS;
-	else if (report_type & PVS)
+	else if ((report_type & PVS) ||
+		 ((report_type & LABEL) && (report_type & VGS)))
 		report_type = PVS;
 	else if (report_type & (SEGS | SEGSSTATUS))
 		report_type = SEGS;


