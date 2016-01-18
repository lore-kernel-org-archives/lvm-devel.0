From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 18 Jan 2016 15:35:39 +0000 (UTC)
Subject: master - pvchange, pvresize: fix lockd_gl() usage
Message-ID: <20160118153539.16EE260C9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54b41dcd53d99059b691f72eb6e7556d4341634d
Commit:        54b41dcd53d99059b691f72eb6e7556d4341634d
Parent:        1ee6af344bd805d4fa847b95b326c2fe1e52d7cd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 15 15:18:25 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 18 09:35:06 2016 -0600

pvchange, pvresize: fix lockd_gl() usage

When an orphan PV is changed/resized, the
lvmlockd global lock is converted from sh
to ex. If the command is changing two
orphan PVs, the conversion to ex should
be done only once.
---
 tools/pvchange.c |    7 +++++--
 tools/pvresize.c |    7 +++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index 91e93c1..fad28d1 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -87,8 +87,11 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	 * i.e. the global lock is only needed for orphans.
 	 * Convert sh to ex.
 	 */
-	if (is_orphan(pv) && !lockd_gl(cmd, "ex", 0))
-		return_ECMD_FAILED;
+	if (is_orphan(pv)) {
+		if (!lockd_gl(cmd, "ex", 0))
+			return_ECMD_FAILED;
+		cmd->lockd_gl_disable = 1;
+	}
 
 	if (tagargs) {
 		/* tag or deltag */
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 0b055e6..ad59bae 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -41,8 +41,11 @@ static int _pvresize_single(struct cmd_context *cmd,
 	 * i.e. the global lock is only needed for orphans.
 	 * Convert sh to ex.
 	 */
-	if (is_orphan(pv) && !lockd_gl(cmd, "ex", 0))
-		return_ECMD_FAILED;
+	if (is_orphan(pv)) {
+		if (!lockd_gl(cmd, "ex", 0))
+			return_ECMD_FAILED;
+		cmd->lockd_gl_disable = 1;
+	}
 
 	if (!pv_resize_single(cmd, vg, pv, params->new_size))
 		return_ECMD_FAILED;


