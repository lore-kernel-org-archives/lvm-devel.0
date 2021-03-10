From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:19:33 +0000 (GMT)
Subject: main - cleanup: use already set vg_complete
Message-ID: <20210310231933.F0B0B3858001@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=23afad824715f941ebeccc2c12aec75fc241b984
Commit:        23afad824715f941ebeccc2c12aec75fc241b984
Parent:        c4f5d9312283b5a096c99d4ccd28b89cbf89b1e7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 14:16:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 11 00:18:01 2021 +0100

cleanup: use already set vg_complete

Already set to 0.
---
 tools/pvscan.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 8bcfe311c..22cb7bc18 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1351,14 +1351,11 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 		}
 
 		if (pvs_unknown) {
-			log_print("pvscan[%d] PV %s online, VG unknown.", getpid(), dev_name(dev));
-			vg_complete = 0;
-
+			log_print("pvscan[%d] PV %s online, VG unknown.",
+				  getpid(), dev_name(dev));
 		} else if (pvs_offline) {
 			log_print("pvscan[%d] PV %s online, VG %s incomplete (need %d).",
 				  getpid(), dev_name(dev), vgname, pvs_offline);
-			vg_complete = 0;
-
 		} else {
 			log_print("pvscan[%d] PV %s online, VG %s is complete.", getpid(), dev_name(dev), vgname);
 			if (!str_list_add(cmd->mem, complete_vgnames, dm_pool_strdup(cmd->mem, vgname)))


