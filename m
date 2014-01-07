From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  7 Jan 2014 01:50:04 +0000 (UTC)
Subject: master - toollib: Fix a mis-merge in _process_all_devs (duplicated pvs -a output).
Message-ID: <20140107015004.2A1C560D66@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=087d33d73b28fcf42f7db5402c80bd174c3d9451
Commit:        087d33d73b28fcf42f7db5402c80bd174c3d9451
Parent:        eaeb33abd4887c668aa88703b6e8981da6f44791
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jan 7 02:49:12 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jan 7 02:49:12 2014 +0100

toollib: Fix a mis-merge in _process_all_devs (duplicated pvs -a output).

---
 tools/toollib.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 0429eb9..bf226b9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -770,9 +770,6 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 
 		ret = process_single_pv(cmd, NULL, pv, handle);
 
-		free_pv_fid(pv);
-
-		ret = process_single_pv(cmd, NULL, pv, handle);
 		if (ret > ret_max)
 			ret_max = ret;
 


