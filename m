From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 14:20:31 +0000 (UTC)
Subject: master - cleanup: make the message about marked PVs consistent with the others
Message-ID: <20160215142031.67FE760AA3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=099d99975c25ba4f4c0593b778c95e7e185fd527
Commit:        099d99975c25ba4f4c0593b778c95e7e185fd527
Parent:        cc9e683adcb6c56332d708baf02dec63eba4fba9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 15 15:20:23 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 15:20:23 2016 +0100

cleanup: make the message about marked PVs consistent with the others

---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 1bdc113..22c38a1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3068,7 +3068,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		pv_name = pv_dev_name(pv);
 
 		if (cmd->system_id && is_orphan(pv) && is_used_pv(pv)) {
-			log_verbose("PV %s is belonging to a VG but its metadata is missing.", pv_name);
+			log_verbose("PV %s is marked as belonging to a VG but its metadata is missing.", pv_name);
 			log_verbose("Skipping PV %s because it's not possible to decide whether it matches system id.", pv_name);
 			continue;
 		}


