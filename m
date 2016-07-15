From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 15 Jul 2016 21:02:55 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160715210255.424AA60F8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d717b52c144699ec1ad096f71088b455cd87faf
Commit:        3d717b52c144699ec1ad096f71088b455cd87faf
Parent:        c425cdd115d56a0f0ec7779934f194af88487905
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 15 21:55:38 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 15 21:55:38 2016 +0100

pre-release

---
 VERSION                          |    2 +-
 VERSION_DM                       |    2 +-
 WHATS_NEW                        |   10 +++++++---
 WHATS_NEW_DM                     |    4 ++--
 libdaemon/server/daemon-server.c |    2 +-
 man/lvm.8.in                     |    5 ++---
 6 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/VERSION b/VERSION
index 822a2c2..2468807 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.161(2)-git (2016-07-06)
+2.02.161(2)-git (2016-07-15)
diff --git a/VERSION_DM b/VERSION_DM
index 4dea605..4cdbea7 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.131-git (2016-07-06)
+1.02.131-git (2016-07-15)
diff --git a/WHATS_NEW b/WHATS_NEW
index 3ed398c..cbd0ceb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,10 @@
-Version 2.02.161 - 
-================================
-  Fix lvresize of filesystem when LV has already right size (2.02.141).
+Version 2.02.161 - 15th July 2016
+=================================
+  Prohibit some lvchange/lvresize that were failing on raid0 volumes.
+  Fix segfaults in complex vgsplits. (2.02.159)
+  Reformat unwieldy lvconvert man page.
+  Allow --force to be passed through to pvcreate from vgcreate. (2.02.144)
+  Fix lvresize of filesystem when LV has already right size (2.02.141)
   New LVM_LOG_FILE_MAX_LINES env var to limit max size of created logs.
 
 Version 2.02.160 - 6th July 2016
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a1d41b4..c02cb3f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.131 -
-================================
+Version 1.02.131 - 15th July 2016
+=================================
   Disable queueing on mpath devs in blk-availability systemd service/initscript.
   Add new -m|--mpathoption disablequeueing to blkdeactivate.
   Automatically group regions with 'create --segments' unless --nogroup.
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index c3402a0..4d65466 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -662,7 +662,7 @@ out:
 
 	if (s.socket_fd >= 0)
 		if (close(s.socket_fd))
-			perror("scoket close");
+			perror("socket close");
 
 	if (s.daemon_fini)
 		if (!s.daemon_fini(&s))
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 82d0558..f0d094d 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -779,9 +779,8 @@ this format string "_%s_%d_%llu".  When set, each process logs to a
 separate file.
 .TP
 .B LVM_LOG_FILE_MAX_LINES
-A max number of lines to be printed to log file before
-the application aborts. Useful for testing to prevent creation
-of too big log files from spinning command.
+If more than this number of lines are sent to the log file, the command gets
+aborted.  Automated tests use this to terminate looping commands.
 .TP
 .B LVM_EXPECTED_EXIT_STATUS
 The status anticipated when the process exits.  Use ">N" to match any


