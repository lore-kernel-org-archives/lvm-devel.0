From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 08:23:42 +0000 (UTC)
Subject: master - cleanup: commit c0f9c79 to work also with for non-clustered configuration
Message-ID: <20140606082342.904E760EB8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=291e55557ee4061a042d6d59b04aa09e6f503386
Commit:        291e55557ee4061a042d6d59b04aa09e6f503386
Parent:        c0f9c79ae8e1df16d23f3eb608fb4bf5455ec841
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 6 10:17:26 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 10:17:26 2014 +0200

cleanup: commit c0f9c79 to work also with for non-clustered configuration

---
 tools/vgchange.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 958919c..fef1301 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -304,6 +304,7 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 			       struct volume_group *vg)
 {
 	int clustered = !strcmp(arg_str_value(cmd, clustered_ARG, "n"), "y");
+	int clvmd_daemon_running = 0;
 
 	if (clustered && (vg_is_clustered(vg))) {
 		log_error("Volume group \"%s\" is already clustered",
@@ -318,7 +319,10 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 	}
 
 	if (clustered && !arg_count(cmd, yes_ARG)) {
-		if (!dm_daemon_is_running(CLVMD_PIDFILE)) {
+#ifdef CLVMD_PIDFILE
+		clvmd_daemon_running = dm_daemon_is_running(CLVMD_PIDFILE);
+#endif
+		if (!clvmd_daemon_running) {
 			if (yes_no_prompt("LVM cluster daemon (clvmd) is not"
 					  " running.\n"
 					  "Make volume group \"%s\" clustered"


