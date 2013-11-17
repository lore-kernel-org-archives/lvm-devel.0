From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:27:04 +0000 (UTC)
Subject: master - report: Iterate over labels instead of PVs for label-only reports.
Message-ID: <20131117222704.F0A3560E9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67a7b7a87da65b2350f975272e581be5f41976e0
Commit:        67a7b7a87da65b2350f975272e581be5f41976e0
Parent:        99214c51eb815806c4a4a4711fa3562546479751
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 29 19:14:51 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:43:06 2013 +0100

report: Iterate over labels instead of PVs for label-only reports.

---
 tools/reporter.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 8b2a7c7..a15f8ef 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -391,8 +391,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 				    report_handle, &_vgs_single);
 		break;
 	case LABEL:
-		r = process_each_pv(cmd, argc, argv, NULL, READ_WITHOUT_LOCK,
-				    1, report_handle, &_label_single);
+		r = process_each_label(cmd, argc, argv,
+				       report_handle, &_label_single);
 		break;
 	case PVS:
 		if (args_are_pvs)


