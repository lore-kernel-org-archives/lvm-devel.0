From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  4 Sep 2015 16:05:25 +0000 (UTC)
Subject: master - man lvmlockctl: add man page
Message-ID: <20150904160525.66DDE60703@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=869c0bdeb89b7f78bb5152ca1278cfb0cc5d9fd5
Commit:        869c0bdeb89b7f78bb5152ca1278cfb0cc5d9fd5
Parent:        c71af0895d4ea3c37bcb06f36eed69a7adcb5296
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 4 11:02:48 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 4 11:05:13 2015 -0500

man lvmlockctl: add man page

---
 man/lvmlockctl.8.in |  102 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 102 insertions(+), 0 deletions(-)

diff --git a/man/lvmlockctl.8.in b/man/lvmlockctl.8.in
new file mode 100644
index 0000000..5465642
--- /dev/null
+++ b/man/lvmlockctl.8.in
@@ -0,0 +1,102 @@
+.TH "LVMLOCKCTL" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+
+.SH NAME
+lvmlockctl \(em Control for lvmlockd 
+
+.SH DESCRIPTION
+This command interacts with
+.BR lvmlockd (8).
+
+.SH OPTIONS
+
+lvmlockctl [options]
+
+.B  \-\-help | \-h
+        Show this help information.
+
+.B  \-\-quit | \-q
+        Tell lvmlockd to quit.
+
+.B  \-\-info | \-i
+        Print lock state information from lvmlockd.
+
+.B  \-\-dump | \-d
+        Print log buffer from lvmlockd.
+
+.B  \-\-wait | \-w 0|1
+        Wait option for other commands.
+
+.B  \-\-force | \-f 0|1
+        Force option for other commands.
+
+.B  \-\-kill | \-k
+.I vgname
+        Kill access to the VG when sanlock cannot renew lease.
+
+.B  \-\-drop | \-r
+.I vgname
+        Clear locks for the VG when it is unused after kill (-k).
+
+.B  \-\-gl\-enable | \-E
+.I vgname
+        Tell lvmlockd to enable the global lock in a sanlock VG.
+
+.B  \-\-gl\-disable | \-D
+.I vgname
+        Tell lvmlockd to disable the global lock in a sanlock VG.
+
+.B  \-\-stop\-lockspaces | \-S
+        Stop all lockspaces.
+
+
+.SH USAGE
+
+.SS info
+
+This collects and displays lock state from lvmlockd.  The display is
+primitive, incomplete and will change in future version.  To print the raw
+lock state from lvmlockd, combine this option with --dump|-d.
+
+.SS dump
+
+This collects the circular log buffer of debug statements from lvmlockd
+and prints it.
+
+.SS kill
+
+This is run by sanlock when it loses access to the storage holding leases
+for a VG.  It currently emits a syslog message stating that the VG must
+be immediately deactivated.  In the future it may automatically attempt to
+forcibly deactivate the VG.  For more, see
+.BR lvmlockd (8).
+
+.SS drop
+
+This should only be run after a VG has been successfully deactivated
+following an lvmlockctl \-\-kill command.  It clears the stale lockspace
+from lvmlockd.  In the future, this may become automatic along with an
+automatic handling of \-\-kill.  For more, see
+.BR lvmlockd (8).
+
+.SS gl\-enable
+
+This enables the global lock in a sanlock VG.  This is necessary if the VG
+that previously held the global lock is removed.  For more, see
+.BR lvmlockd (8).
+
+.SS gl\-disable
+
+This disables the global lock in a sanlock VG.  This is necessary if the
+global lock has mistakenly been enabled in more than one VG.  The global
+lock should be disabled in all but one sanlock VG.  For more, see
+.BR lvmlockd (8).
+
+.SS stop\-lockspaces
+
+This tells lvmlockd to stop all lockspaces.  It can be useful to stop
+lockspaces for VGs that the vgchange \-\-lock\-stop comand can no longer
+see, or to stop the dlm global lockspace which is not directly stopped by
+the vgchange command.  The wait and force options can be used with this
+command.
+
+


