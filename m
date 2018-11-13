From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Nov 2018 18:28:54 -0500
Subject: master - man: remove lvmetad
Message-ID: <201811132328.wADNSswK006717@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c0b02e367a4686d2331f140c999aa3b4f26cea7
Commit:        1c0b02e367a4686d2331f140c999aa3b4f26cea7
Parent:        8aec65c0546ffaf5f40ab6fce7616e237cb17960
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 13 16:22:34 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 13 16:22:34 2018 -0600

man: remove lvmetad

---
 man/Makefile.in    |    9 +---
 man/lvmetad.8_main |  129 ----------------------------------------------------
 2 files changed, 2 insertions(+), 136 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 25e6fa6..e73f834 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -26,7 +26,6 @@ FSADMMAN = fsadm.8
 BLKDEACTIVATEMAN = blkdeactivate.8
 DMEVENTDMAN = dmeventd.8
 DMFILEMAPDMAN = dmfilemapd.8
-LVMETADMAN = lvmetad.8
 LVMPOLLDMAN = lvmpolld.8
 LVMLOCKDMAN = lvmlockd.8 lvmlockctl.8
 CMIRRORDMAN = cmirrord.8
@@ -60,7 +59,7 @@ ifeq ($(MAKECMDGOALS),install_all_man)
 endif
 
 ifeq ($(MAN_ALL),"yes")
-  MAN8+=$(FSADMMAN) $(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN)
+  MAN8+=$(FSADMMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN)
   MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(DMFILEMAPDMAN)
   MAN8CLUSTER+=$(CMIRRORDMAN)
 else
@@ -72,10 +71,6 @@ else
     MAN8+=$(LVMDBUSDMAN)
   endif
 
-  ifeq ("@BUILD_LVMETAD@", "yes")
-    MAN8+=$(LVMETADMAN)
-  endif
-
   ifeq ("@BUILD_LVMPOLLD@", "yes")
     MAN8+=$(LVMPOLLDMAN)
   endif
@@ -114,7 +109,7 @@ include $(top_builddir)/make.tmpl
 CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8:%.8=%.8_gen) $(MAN8CLUSTER) \
 	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM) $(TESTMAN)
 DISTCLEAN_TARGETS+=$(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) \
-	$(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CMIRRORDMAN) \
+	$(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CMIRRORDMAN) \
 	$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMDBUSDMAN) $(LVMRAIDMAN) \
 	$(DMFILEMAPDMAN)
 
diff --git a/man/lvmetad.8_main b/man/lvmetad.8_main
deleted file mode 100644
index ec55171..0000000
--- a/man/lvmetad.8_main
+++ /dev/null
@@ -1,129 +0,0 @@
-.TH LVMETAD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
-.SH NAME
-lvmetad \(em LVM metadata cache daemon
-
-.SH SYNOPSIS
-.B lvmetad
-.RB [ -l
-.IR level [,level...]]
-.RB [ -p
-.IR pidfile_path ]
-.RB [ -s
-.IR socket_path ]
-.RB [ -t
-.IR timeout_value ]
-.RB [ -f ]
-.RB [ -h ]
-.RB [ -V ]
-.RB [ -? ]
-
-.SH DESCRIPTION
-
-The lvmetad daemon caches LVM metadata so that LVM commands can read
-metadata from the cache rather than scanning disks.  This can be an
-advantage because scanning disks is time consuming and may interfere with
-the normal work of the system.  lvmetad can be a disadvantage when disk
-event notifications from the system are unreliable.
-
-lvmetad does not read metadata from disks itself.  Instead, it relies on
-an LVM command, like pvscan --cache, to read metadata from disks and
-send it to lvmetad to be cached.
-
-New LVM disks that appear on the system must be scanned before lvmetad
-knows about them.  If lvmetad does not know about a disk, then LVM
-commands using lvmetad will also not know about it.  When disks are added
-or removed from the system, lvmetad must be updated.
-
-lvmetad is usually combined with event-based system services that
-automatically run pvscan --cache on disks added or removed.  This way,
-the cache is automatically updated with metadata from new disks when they
-appear.  LVM udev rules and systemd services implement this automation.
-Automatic scanning is usually combined with automatic activation.  For
-more information, see
-.BR pvscan (8).
-
-If lvmetad is started or restarted after disks have been added to the
-system, or if the global_filter has changed, the cache must be updated.
-This can be done by running pvscan --cache, or it will be done
-automatically by the next LVM command that's run.
-
-When lvmetad is not used, LVM commands revert to scanning disks for LVM
-metadata.
-
-In some cases, lvmetad will be temporarily disabled while it continues
-running.  In this state, LVM commands will ignore the lvmetad cache and
-revert to scanning disks.  A warning will also be printed which includes
-the reason why lvmetad is not being used.  The most common reasons are the
-existence of duplicate PVs (lvmetad cannot cache data for duplicate PVs),
-or an 'lvconvert --repair' command has been run (the lvmetad cache may
-not be reliable while repairs are neeeded.)
-Once duplicates have been resolved, or repairs have been completed,
-the lvmetad cache is can be updated with pvscan --cache and commands
-will return to using the cache.
-
-Use of lvmetad is enabled/disabled by:
-.br
-.BR lvm.conf (5)
-.B global/use_lvmetad
-
-For more information on this setting, see:
-.br
-.B lvmconfig --withcomments global/use_lvmetad
-
-To ignore disks from LVM at the system level, e.g. lvmetad, pvscan use:
-.br
-.BR lvm.conf (5)
-.B devices/global_filter
-
-For more information on this setting, see
-.br
-.B lvmconfig --withcomments devices/global_filter
-
-.SH OPTIONS
-
-To run the daemon in a test environment both the pidfile_path and the
-socket_path should be changed from the defaults.
-.TP
-.B -f
-Don't fork, but run in the foreground.
-.TP
-.BR -h ", " -?
-Show help information.
-.TP
-.B -l \fIlevels
-Specify the levels of log messages to generate as a comma separated list.
-Messages are logged by syslog.
-Additionally, when -f is given they are also sent to standard error.
-Possible levels are: all, fatal, error, warn, info, wire, debug.
-.TP
-.B -p \fIpidfile_path
-Path to the pidfile. This overrides both the built-in default
-(#DEFAULT_PID_DIR#/lvmetad.pid) and the environment variable
-\fBLVM_LVMETAD_PIDFILE\fP.  This file is used to prevent more
-than one instance of the daemon running simultaneously.
-.TP
-.B -s \fIsocket_path
-Path to the socket file. This overrides both the built-in default
-(#DEFAULT_RUN_DIR#/lvmetad.socket) and the environment variable
-\fBLVM_LVMETAD_SOCKET\fP.  To communicate successfully with lvmetad,
-all LVM2 processes should use the same socket path.
-.TP
-.B -t \fItimeout_value
-The daemon may shutdown after being idle for the given time (in seconds). When the
-option is omitted or the value given is zero the daemon never shutdowns on idle.
-.TP
-.B -V
-Display the version of lvmetad daemon.
-.SH ENVIRONMENT VARIABLES
-.TP
-.B LVM_LVMETAD_PIDFILE
-Path for the pid file.
-.TP
-.B LVM_LVMETAD_SOCKET 
-Path for the socket file.
-
-.SH SEE ALSO
-.BR lvm (8),
-.BR lvmconfig (8),
-.BR lvm.conf (5),
-.BR pvscan (8)


