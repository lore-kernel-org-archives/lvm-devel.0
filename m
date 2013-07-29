From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Jul 2013 21:19:23 +0200
Subject: [PATCH 19/20] report: Iterate over labels instead of PVs for label-only reports.
In-Reply-To: <1375125564-1188-1-git-send-email-prockai@redhat.com>
References: <1375125564-1188-1-git-send-email-prockai@redhat.com>
Message-ID: <1375125564-1188-19-git-send-email-prockai@redhat.com>
	(sfid-20130729_211929_809948_C54E9CB4)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 tools/reporter.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 6bf2048..5602883 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -362,8 +362,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
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
-- 
1.8.2


