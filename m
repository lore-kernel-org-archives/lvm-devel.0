From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  5 Mar 2021 12:01:47 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20210305120147.3BCCB3870902@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2244a56021475179b8cc3633c8cb6534eaa18025
Commit:        2244a56021475179b8cc3633c8cb6534eaa18025
Parent:        3bea8937334ab9a7852947a30862d6e457f093b6
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Mar 5 12:53:35 2021 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Mar 5 12:53:35 2021 +0100

make: generate

---
 conf/example.conf.in | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 8ac376303..204ec82d1 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1122,6 +1122,17 @@ global {
 	# This configuration option has an automatic default value.
 	# sanlock_lv_extend = 256
 
+	# Configuration option global/lvmlockctl_kill_command.
+	# The command that lvmlockctl --kill should use to force LVs offline.
+	# The lvmlockctl --kill command is run when a shared VG has lost
+	# access to locks (e.g. when sanlock has lost access to storage.)
+	# An empty string means that there will be no automatic attempt by
+	# lvmlockctl --kill to forcibly shut down LVs in the VG, and the user
+	# can manually intervene as described in lvmlockd(8).
+	# The VG name will be appended to the command specified here.
+	# This configuration option has an automatic default value.
+	# lvmlockctl_kill_command = ""
+
 	# Configuration option global/thin_check_executable.
 	# The full path to the thin_check command.
 	# LVM uses this command to check that a thin metadata device is in a


