From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  5 Nov 2014 09:47:03 +0000 (UTC)
Subject: master - cleanup: keep 'fall through' switch case for LVSINFO for compiler to understand this properly
Message-ID: <20141105094703.9998360CD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3261e539a01efffb56abd78e5a060af8d1cf1537
Commit:        3261e539a01efffb56abd78e5a060af8d1cf1537
Parent:        bf4681ba134914e5847d94bc0ca01b7a2af0b2b5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 5 10:46:52 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 5 10:46:52 2014 +0100

cleanup: keep 'fall through' switch case for LVSINFO for compiler to understand this properly

---
 tools/reporter.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 080e3d5..b49f37d 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -414,6 +414,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	case DEVTYPES:
 		r = _process_each_devtype(cmd, argc, report_handle);
 		break;
+	case LVSINFO:
+		/* fall through */
 	case LVS:
 		r = process_each_lv(cmd, argc, argv, 0, report_handle,
 				    lv_info_needed ? &_lvs_with_info_single


