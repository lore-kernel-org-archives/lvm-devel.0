From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:29 +0000 (UTC)
Subject: master - example.conf.in: apply previous improvements to example.conf
Message-ID: <20150515183729.7A57060E34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d15217a6c08d99314324469f42ad9b8cd0baccc
Commit:        0d15217a6c08d99314324469f42ad9b8cd0baccc
Parent:        9f0095fa2c2c3ceb542be7d3da54072dd6c2bef5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 15 14:28:30 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:32:58 2015 +0200

example.conf.in: apply previous improvements to example.conf

---
 conf/example.conf.in |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index cc02e98..e809488 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -939,14 +939,16 @@ global {
 	# This configuration option does not have a default value defined.
 	# system_id_file = ""
 
-	# Indicates whether to use lvmpolld instead of classical polldaemon (a process
-	# forked off an initiating lvm command) or not. When set to 1 and native systemd
-	# service is installed in the system lvm starts using lvmpolld. lvmpolld gets
-	# auto-activated by systemd when a message lands on the respective lvmpolld socket.
-	# All commands that would require polling of in-progress operation are therefore
-	# spawned in lvmpolld's service cgroup.
-	#
-	# When set to 0 lvm falls back to classical polling.
+	# Use lvmpolld to supervise long running LVM commands.
+	# When enabled, control of long running LVM commands is transferred
+	# from the original LVM command to the lvmpolld daemon. This allows
+	# the operation to continue independent of the original LVM command.
+	# After lvmpolld takes over, the LVM command displays the progress
+	# of the ongoing operation. lvmpolld itself runs LVM commands to manage
+	# the progress of ongoing operations. lvmpolld can be used as a native
+	# systemd service, which allows it to be started on demand, and to use
+	# its own control group. When this option is disabled, LVM commands will
+	# supervise long running operations by forking themselves.
 	use_lvmpolld = @DEFAULT_USE_LVMPOLLD@
 }
 


