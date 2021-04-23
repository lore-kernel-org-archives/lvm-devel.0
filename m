From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:53 +0000 (GMT)
Subject: main - cov: ensure fid is not null
Message-ID: <20210423210553.EF2B2394480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e1287c3b711d9d77221b0114dbb5ebd84c09ca48
Commit:        e1287c3b711d9d77221b0114dbb5ebd84c09ca48
Parent:        04fd55a0c9e721e8d73f067f886736377ba879e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 15:11:23 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: ensure fid is not null

---
 tools/pvscan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 83f3f3983..df38e1758 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1232,7 +1232,8 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 
 		if (!vg) {
 			log_print("pvscan[%d] PV %s has no VG metadata.", getpid(), dev_name(dev));
-			fmt->ops->destroy_instance(fid);
+			if (fid)
+				fmt->ops->destroy_instance(fid);
 			goto online;
 		}
 


