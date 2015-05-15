From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:44 +0000 (UTC)
Subject: master - lvmpolld.8.in: man page rewrite
Message-ID: <20150515183744.306E4613FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77fa958c1e019cccebf30a92edfec07970e9f927
Commit:        77fa958c1e019cccebf30a92edfec07970e9f927
Parent:        d4317c040635a67c62df95bd102e03575d49f09d
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu May 14 19:33:27 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:33:47 2015 +0200

lvmpolld.8.in: man page rewrite

- add client functionality
- fill in long option variants
---
 man/lvmpolld.8.in |   57 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/man/lvmpolld.8.in b/man/lvmpolld.8.in
index 462ac1f..5906f42 100644
--- a/man/lvmpolld.8.in
+++ b/man/lvmpolld.8.in
@@ -3,73 +3,80 @@
 lvmpolld \(em LVM poll daemon
 .SH SYNOPSIS
 .B lvmpolld
-.RB [ \-l
+.RB [ \-l | \-\-log
 .RI { all | wire | debug }]
-.RB [ \-p
+.RB [ \-p | \-\-pidfile
 .IR pidfile_path ]
-.RB [ \-s
+.RB [ \-s | \-\-socket
 .IR socket_path ]
-.RB [ \-B
+.RB [ \-B | \-\-binary
 .IR lvm_binary_path ]
-.RB [ \-t
+.RB [ \-t | \-\-timeout
 .IR timeout_value ]
-.RB [ \-f ]
-.RB [ \-h ]
-.RB [ \-V ]
-.RB [ \-? ]
+.RB [ \-f | \-\-foreground ]
+.RB [ \-h | \-\-help ]
+.RB [ \-V | \-\-version ]
+
+.B lvmpolld
+.RB [ \-\-dump ]
 .SH DESCRIPTION
 lvmpolld is polling daemon for LVM. The daemon receives requests for polling
 of already initialised operations originating in LVM2 command line tool.
-The requests for polling originates in \fBlvconvert\fP, \fBpvmove\fP,
-\fBlvchange\fP or \fBvgchange\fP LVM2 command.
+The requests for polling originate in the \fBlvconvert\fP, \fBpvmove\fP,
+\fBlvchange\fP or \fBvgchange\fP LVM2 commands.
 
 The purpose of lvmpolld is to reduce the number of spawned background processes
-per otherwise unique polling operation. There should be only one. It also eliminates
-the possibility of unsolicited termination of background process by external factors.
+per otherwise unique polling operation. There should be only one. It also
+eliminates the possibility of unsolicited termination of background process by
+external factors.
 
-lvmpolld is used by LVM only if it is enabled in \fBlvm.conf\fP(5) by specifying the
-\fBglobal/use_lvmpolld\fP setting. If this is not defined in the LVM configuration
-explicitly then default setting is used instead (see the output of
-\fBlvmconfig \-\-type default global/use_lvmpolld\fP command).
+lvmpolld is used by LVM only if it is enabled in \fBlvm.conf\fP(5) by
+specifying the \fBglobal/use_lvmpolld\fP setting. If this is not defined in the
+LVM configuration explicitly then default setting is used instead (see the
+output of \fBlvmconfig \-\-type default global/use_lvmpolld\fP command).
 .SH OPTIONS
 
 To run the daemon in a test environment both the pidfile_path and the
 socket_path should be changed from the defaults.
 .TP
-.B \-f
+.BR \-f ", " \-\-foreground
 Don't fork, but run in the foreground.
 .TP
-.BR \-h ", " \-?
+.BR \-h ", " \-\-help
 Show help information.
 .TP
-.IR \fB\-l " {" all | wire | debug }
+.IR \fB\-l\fP ", " \fB\-\-log\fP " {" all | wire | debug }
 Select the type of log messages to generate.
 Messages are logged by syslog.
 Additionally, when \-f is given they are also sent to standard error.
 There are two classes of messages: wire and debug. Selecting 'all' supplies both
 and is equivalent to a comma-separated list \-l wire,debug.
 .TP
-.B \-p \fIpidfile_path
+.BR \-p ", " \-\-pidfile \fIpidfile_path
 Path to the pidfile. This overrides both the built-in default
 (#DEFAULT_PID_DIR#/lvmpolld.pid) and the environment variable
 \fBLVM_LVMPOLLD_PIDFILE\fP.  This file is used to prevent more
 than one instance of the daemon running simultaneously.
 .TP
-.B \-s \fIsocket_path
+.BR \-s ", " \-\-socket " " \fIsocket_path
 Path to the socket file. This overrides both the built-in default
 (#DEFAULT_RUN_DIR#/lvmpolld.socket) and the environment variable
 \fBLVM_LVMPOLLD_SOCKET\fP.
 .TP
-.B \-t \fItimeout_value
+.BR \-t ", " \-\-timeout " " \fItimeout_value
 The daemon may shutdown after being idle for the given time (in seconds). When the
 option is omitted or the value given is zero the daemon never shutdowns on idle.
 .TP
-.B \-B \fIlvm_binary_path
+.BR \-B ", " \-\-binary " " \fIlvm_binary_path
 Optional path to alternative LVM binary (default: #LVM_PATH#). Use for
 testing purposes only.
 .TP
-.B \-V
+.BR \-V ", " \-\-version
 Display the version of lvmpolld daemon.
+.TP
+.B \-\-dump
+Contact the running lvmpolld daemon to obtain the complete state and print it
+out in a raw format.
 .SH ENVIRONMENT VARIABLES
 .TP
 .B LVM_LVMPOLLD_PIDFILE


