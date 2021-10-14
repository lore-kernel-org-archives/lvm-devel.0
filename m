From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 22:09:59 +0000 (GMT)
Subject: main - gcc: always initialize vg_complete
Message-ID: <20211014220959.424E53858419@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=04725763a1eb20565cc66e1fd009d9ee93220524
Commit:        04725763a1eb20565cc66e1fd009d9ee93220524
Parent:        14cf579263cb9121a8f06396c6257453492e043b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 14 23:43:12 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 00:09:07 2021 +0200

gcc: always initialize vg_complete

---
 tools/pvscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 6ea7a77e5..8e2611361 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1295,7 +1295,7 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 	int pvs_online;
 	int pvs_offline;
 	int pvs_unknown;
-	int vg_complete;
+	int vg_complete = 0;
 	int do_full_check;
 	int ret = 1;
 


