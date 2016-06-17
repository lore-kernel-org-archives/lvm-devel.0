From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 17 Jun 2016 11:29:52 +0000 (UTC)
Subject: master - tools: add missing destroy_processing_handle in pvscan and vgreduce code
Message-ID: <20160617112952.2994960D5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a23655ab3bea4dfe9409c8c6b238787da9b457e1
Commit:        a23655ab3bea4dfe9409c8c6b238787da9b457e1
Parent:        f77fe436afb76ddb798d236d34daf50413a184f6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 17 13:29:33 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 17 13:29:33 2016 +0200

tools: add missing destroy_processing_handle in pvscan and vgreduce code

---
 tools/pvscan.c   |    1 +
 tools/vgreduce.c |    7 +++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 73a97be..9b50374 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -655,6 +655,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 
 out:
 	unlock_vg(cmd, VG_GLOBAL);
+	destroy_processing_handle(cmd, handle);
 
 	return ret;
 }
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index a10e12c..19a0bb0 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -237,8 +237,10 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	vp.force = arg_count(cmd, force_ARG);
 
 	/* Needed to change the set of orphan PVs. */
-	if (!lockd_gl(cmd, "ex", 0))
-		return_ECMD_FAILED;
+	if (!lockd_gl(cmd, "ex", 0)) {
+		ret = ECMD_FAILED;
+		goto_out;
+	}
 	cmd->lockd_gl_disable = 1;
 
 	cmd->handles_missing_pvs = 1;
@@ -259,6 +261,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 		ret = ECMD_FAILED;
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
+	destroy_processing_handle(cmd, handle);
 
 	return ret;
 }


