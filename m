From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:05 +0000 (GMT)
Subject: main - cov: ensure there is either vg or error_vg
Message-ID: <20230506204605.2EF5F3858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fae0ed8f10bc5771423f2b7af63690800de1ce9f
Commit:        fae0ed8f10bc5771423f2b7af63690800de1ce9f
Parent:        871d9f379f79f1969d71b660164efe18515826c2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 26 13:38:22 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 19:22:05 2023 +0200

cov: ensure there is either vg or error_vg

Make it explicitely visible to coverity that
_process_pvs_in_vg() is not passing  NULL vg.
---
 tools/toollib.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 43e628abf..c2d93aaf9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4525,7 +4525,8 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		error_flags = 0;
 
 		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state, &error_flags, &error_vg);
-		if (_ignore_vg(cmd, error_flags, error_vg, vg_name, NULL, read_flags, &skip, &notfound)) {
+		if (_ignore_vg(cmd, error_flags, error_vg, vg_name, NULL, read_flags, &skip, &notfound) ||
+		    (!vg && !error_vg)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			report_log_ret_code(ret_max);
@@ -4535,7 +4536,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		}
 		if (notfound)
 			goto endvg;
-		
+
 		/*
 		 * Don't call "continue" when skip is set, because we need to remove
 		 * error_vg->pvs entries from devices list.

