From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:18 +0000 (UTC)
Subject: master - lvm-lvpoll.8.in: man page for built-in command
Message-ID: <20150515183718.E5A27610DA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce3c457dcc4385c6740bacf1b0e9ca7575ab8c10
Commit:        ce3c457dcc4385c6740bacf1b0e9ca7575ab8c10
Parent:        239fb95fde143145f5dc3b3c65189b3549e2f7a6
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 15 20:16:51 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:32:16 2015 +0200

lvm-lvpoll.8.in: man page for built-in command

---
 man/Makefile.in     |    2 +-
 man/lvm-lvpoll.8.in |   89 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 90 insertions(+), 1 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index fd92372..d75d916 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -48,7 +48,7 @@ endif
 
 MAN5=lvm.conf.5
 MAN7=lvmsystemid.7
-MAN8=lvm-config.8 lvm-dumpconfig.8 \
+MAN8=lvm-config.8 lvm-dumpconfig.8 lvm-lvpoll.8 \
 	lvchange.8 lvmconfig.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 \
 	lvm.8 lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \
 	lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
diff --git a/man/lvm-lvpoll.8.in b/man/lvm-lvpoll.8.in
new file mode 100644
index 0000000..8ffbdd4
--- /dev/null
+++ b/man/lvm-lvpoll.8.in
@@ -0,0 +1,89 @@
+.TH "LVPOLL" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" \" -*- nroff -*-
+.SH NAME
+lvpoll \(em Internal command used by lvmpolld to complete some Logical Volume operations.
+
+.SH SYNOPSIS
+.B lvm lvpoll
+.BR \-\-polloperation
+.RI { pvmove | convert | merge | merge_thin }
+.RB [ \-\-abort ]
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-handlemissingpvs ]
+.RB [ \-i | \-\-interval
+.IR Seconds ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR LogicalVolume [ Path ]
+.SH DESCRIPTION
+\fBlvpoll\fP is an internal command used by \fBlvmpolld\fP(8) to monitor and
+complete \fBlvconvert\fP(8) and \fBpvmove\fP(8) operations.
+\fBlvpoll\fP itself does not initiate these operations and
+you should never normally need to invoke it directly.
+
+.I LogicalVolume
+The Logical Volume undergoing conversion or, in the case of pvmove, the name of
+the internal pvmove Logical Volume (see \fBEXAMPLES\fP).
+.SH OPTIONS
+See \fBlvm\fP(8) for common options.
+.TP
+.BR \-\-polloperation " {" \fIconvert | \fImerge | \fImerge_thin | \fIpvmove }
+Mandatory option.
+\fIpvmove\fP refers to a pvmove operation that is moving data.
+\fIconvert\fP refers to an operation that is increasing the number of redundant copies of data maintained by a mirror.
+\fImerge\fP indicates a merge operation that doesn't involve thin volumes.
+\fImerge_thin\fP indicates a merge operation involving thin snapshots.
+\fBpvmove\fP(8) and \fBlvconvert\fP(8) describe how to initiate these operations.
+.TP
+.B \-\-abort
+Abort pvmove in progress.  See \fBpvmove\fP(8).
+.TP
+.B \-\-handlemissingpvs
+Used when the polling operation needs to handle missing PVs to be able to
+continue. This can happen when \fBlvconvert\fP(8) is repairing a mirror
+with one or more faulty devices.
+.TP
+.BR \-i ", " \-\-interval " "\fISeconds
+Report progress at regular intervals
+
+.SH EXAMPLES
+Resume polling of a pvmove operation identified by the Logical Volume vg00/pvmove0:
+.sp
+.B lvm lvpoll --polloperation pvmove vg00/pvmove0
+.P
+Abort the same pvmove operation:
+.sp
+.B lvm lvpoll --polloperation pvmove --abort vg00/pvmove0
+.P
+To find out the name of the pvmove Logical Volume resulting from an original
+\fBpvmove /dev/sda1\fP command you may use the following \fBlvs\fP command.
+(Remove the parentheses from the LV name.)
+.sp
+.B lvs -a -S move_pv=/dev/sda1
+.P
+Resume polling of mirror conversion vg00/lvmirror:
+.sp
+.B lvm lvpoll --polloperation convert vg00/lvmirror
+.P
+Complete mirror repair:
+.sp
+.B lvm lvpoll --polloperation convert vg/damaged_mirror --handlemissingpvs
+.P
+Process snapshot merge:
+.sp
+.B lvm lvpoll --polloperation merge vg/snapshot_old
+.P
+Finish thin snapshot merge:
+.sp
+.B lvm lvpoll --polloperation merge_thin vg/thin_snapshot
+.SH SEE ALSO
+.BR lvconvert (8),
+.BR lvm (8),
+.BR lvmpolld (8),
+.BR lvs (8),
+.BR pvmove (8)


