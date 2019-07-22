From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Jul 2019 13:23:18 -0400
Subject: stable-2.02 - vgrename: use global lock
Message-ID: <201907221723.x6MHNI99020010@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d980172b076547865efe5ca0839cabedc05a7b9
Commit:        3d980172b076547865efe5ca0839cabedc05a7b9
Parent:        e3c8cebd87f9bd7591529f3d65783cc6f1fd3f92
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 22 12:12:42 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 22 12:22:12 2019 -0500

vgrename: use global lock

Should fix a reported problem of pvs seeing bad orphan
info while vgrename was running.
---
 tools/vgrename.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/vgrename.c b/tools/vgrename.c
index 4f2a08b..f13289e 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -202,6 +202,11 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 	if (!(vp.vg_name_new = dm_pool_strdup(cmd->mem, vg_name_new)))
 		return_ECMD_FAILED;
 
+	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
+		log_error("Unable to obtain global lock.");
+		return_ECMD_FAILED;
+	}
+
 	/* Needed change the global VG namespace. */
 	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
 		return_ECMD_FAILED;


