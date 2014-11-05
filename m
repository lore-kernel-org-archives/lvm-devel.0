From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  5 Nov 2014 09:42:28 +0000 (UTC)
Subject: master - report: cleanup: simplify LVSINFO detection
Message-ID: <20141105094228.B30566092E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf4681ba134914e5847d94bc0ca01b7a2af0b2b5
Commit:        bf4681ba134914e5847d94bc0ca01b7a2af0b2b5
Parent:        160777bb3eda1cae32511292070c92e076305ef6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 5 10:35:38 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 5 10:42:18 2014 +0100

report: cleanup: simplify LVSINFO detection

LVSINFO is just a subtype of LVS report type with extra "info" ioctl
called for each LV reported (per output line) so include its processing
within "case LVS" switch, not as completely different kind of reporting
which may be misleading when reading the code.

There's already the "lv_info_needed" flag set in the _report fn, so
call the approriate reporting function based on this flag within the
"case LVS" switch line.

Actually the same is already done for LV is reported per segments
within the "case SEGS" switch line. So this patch makes the code more
consistent so it's processed the same way for all cases.

Also, this is a preparation for another and new subtype that will
be introduced later - the "LVSSTATUS" and "SEGSSTATUS" report type.
---
 tools/reporter.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 02f6064..080e3d5 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -394,9 +394,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		report_type = PVS;
 	else if (report_type & SEGS)
 		report_type = SEGS;
-	else if (report_type & LVSINFO)
-		report_type = LVSINFO;
-	else if (report_type & LVS)
+	else if (report_type & (LVS | LVSINFO))
 		report_type = LVS;
 
 	/*
@@ -418,11 +416,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		break;
 	case LVS:
 		r = process_each_lv(cmd, argc, argv, 0, report_handle,
-				    &_lvs_single);
-		break;
-	case LVSINFO:
-		r = process_each_lv(cmd, argc, argv, 0, report_handle,
-				    &_lvs_with_info_single);
+				    lv_info_needed ? &_lvs_with_info_single
+						   : &_lvs_single);
 		break;
 	case VGS:
 		r = process_each_vg(cmd, argc, argv, 0,


