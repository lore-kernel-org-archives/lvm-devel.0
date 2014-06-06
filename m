From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:23:14 +0000 (UTC)
Subject: master - cleanup: move the "daemon is running" checks to lvm-wrappers
Message-ID: <20140606122314.DDB006019A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=943f3aec3d20169045ec2d2f4a07d87827cb95d8
Commit:        943f3aec3d20169045ec2d2f4a07d87827cb95d8
Parent:        f115a4a53fe6c3a3121e200c7f8796fb086c0c6e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 6 14:21:09 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 14:21:09 2014 +0200

cleanup: move the "daemon is running" checks to lvm-wrappers

And use ifdefs there, not exposing it in the tool code itself.
Later in the future, we should probably make the PIDFILE and
daemon checking code available also in case the daemon itself
is not built.
---
 lib/mirror/mirrored.c   |    2 +-
 lib/misc/lvm-wrappers.c |   24 ++++++++++++++++++++++++
 lib/misc/lvm-wrappers.h |    4 ++++
 tools/vgchange.c        |    6 +-----
 4 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index e3f768f..5040011 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -497,7 +497,7 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 		 * otherwise, the kernel module will fail to make
 		 * contact.
 		 */
-		if (dm_daemon_is_running(CMIRRORD_PIDFILE)) {
+		if (cmirrord_is_running()) {
 			struct utsname uts;
 			unsigned kmaj, kmin, krel;
 			/*
diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index 5604ce7..4e3ff33 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -139,3 +139,27 @@ unsigned lvm_even_rand(unsigned *seed, unsigned max)
 
 	return ret;
 }
+
+#ifdef CLVMD_PIDFILE
+inline int clvmd_is_running(void)
+{
+	return dm_daemon_is_running(CLVMD_PIDFILE);
+}
+#else
+inline int clvmd_is_running(void)
+{
+	return 0;
+}
+#endif
+
+#ifdef CMIRRORD_PIDFILE
+inline int cmirrord_is_running(void)
+{
+	return dm_daemon_is_running(CMIRRORD_PIDFILE);
+}
+#else
+inline int cmirrord_is_running(void)
+{
+	return 0;
+}
+#endif
diff --git a/lib/misc/lvm-wrappers.h b/lib/misc/lvm-wrappers.h
index 137cbdb..fbf28b8 100644
--- a/lib/misc/lvm-wrappers.h
+++ b/lib/misc/lvm-wrappers.h
@@ -37,4 +37,8 @@ int read_urandom(void *buf, size_t len);
  */
 unsigned lvm_even_rand(unsigned *seed, unsigned max);
 
+inline int clvmd_is_running(void);
+inline int cmirrord_is_running(void);
+
+
 #endif
diff --git a/tools/vgchange.c b/tools/vgchange.c
index fef1301..2556af2 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -304,7 +304,6 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 			       struct volume_group *vg)
 {
 	int clustered = !strcmp(arg_str_value(cmd, clustered_ARG, "n"), "y");
-	int clvmd_daemon_running = 0;
 
 	if (clustered && (vg_is_clustered(vg))) {
 		log_error("Volume group \"%s\" is already clustered",
@@ -319,10 +318,7 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 	}
 
 	if (clustered && !arg_count(cmd, yes_ARG)) {
-#ifdef CLVMD_PIDFILE
-		clvmd_daemon_running = dm_daemon_is_running(CLVMD_PIDFILE);
-#endif
-		if (!clvmd_daemon_running) {
+		if (!clvmd_is_running()) {
 			if (yes_no_prompt("LVM cluster daemon (clvmd) is not"
 					  " running.\n"
 					  "Make volume group \"%s\" clustered"


