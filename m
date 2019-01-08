From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 8 Jan 2019 07:16:27 -0500
Subject: master - generators: avoid contacting syslog with generators
Message-ID: <201901081216.x08CGRhT031872@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fdd612b8242281ac599c220726155202c71549a8
Commit:        fdd612b8242281ac599c220726155202c71549a8
Parent:        6298eaeca50e32cdff3adefdb57b09c3250547a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 7 15:48:39 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 8 13:13:54 2019 +0100

generators: avoid contacting syslog with generators

The systemd generators are executed very early during the switch
from initramfs to system partition and the syslog is not yet fully
operational - it may cause blocking, if some debug logging is enabled
at the same time in /etc/lvm/lvm.conf log{} section.

To avoid timeouting and killing this generator - rather enhance lvm
code to suppress any syslog communication when LVM_SUPPRESS_SYSLOG
envvar is set.

Use of this envvar is needed since the parsing of i.e. cmdline options
that could eventually override lvm.conf setting happens in this case
way too late and number of lines could have been already streamed to
syslog.
---
 WHATS_NEW                     |    1 +
 lib/log/log.c                 |    3 +++
 man/lvm.8_main                |    3 +++
 scripts/generator-internals.c |    3 +++
 4 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6fdde83..822d045 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Introduce LVM_SUPPRESS_SYSLOG to suppress syslog usage by generator.
   Fix generator quering lvmconfig unpresent config option.
   Fix memleak on bcache error path code.
   Fix missing unlock on lvm2 dmeventd plugin error path initialization.
diff --git a/lib/log/log.c b/lib/log/log.c
index fd056b1..f6aaa04 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -324,6 +324,9 @@ void init_log_while_suspended(int log_while_suspended)
 
 void init_syslog(int facility)
 {
+	if (getenv("LVM_SUPPRESS_SYSLOG"))
+		return;
+
 	openlog("lvm", LOG_PID, facility);
 	_syslog = 1;
 }
diff --git a/man/lvm.8_main b/man/lvm.8_main
index b9abf58..3e67b1b 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -435,6 +435,9 @@ Defaults to "\fI#DEFAULT_SYS_DIR#\fP".
 .B LVM_SUPPRESS_FD_WARNINGS
 Suppress warnings about unexpected file descriptors passed into LVM.
 .TP
+.B LVM_SUPPRESS_SYSLOG
+Suppress contacting syslog.
+.TP
 .B LVM_VG_NAME
 The Volume Group name that is assumed for
 any reference to a Logical Volume that doesn't specify a path.
diff --git a/scripts/generator-internals.c b/scripts/generator-internals.c
index 8392065..733e818 100644
--- a/scripts/generator-internals.c
+++ b/scripts/generator-internals.c
@@ -72,6 +72,9 @@ static bool _open_child(struct child_process *child, const char *cmd, const char
 			(void) close(pipe_fd[1]);
 		}
 
+		/* Suppressing any use of syslog */
+		(void) setenv("LVM_SUPPRESS_SYSLOG", "1", 1);
+
 		if (execv(cmd, (char *const *) argv) < 0)
 			_error("execv failed: %s\n", strerror(errno));
 		// Shouldn't get here unless exec failed.


