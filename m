From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Jul 2012 12:04:13 +0000 (UTC)
Subject: master - activate: skip manual activation for --sysinit -aay
Message-ID: <20120710120413.9FECC119B@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd8ea8b437de53f0019bd69d542a7d01f3d5b7d3
Commit:        cd8ea8b437de53f0019bd69d542a7d01f3d5b7d3
Parent:        8767435ef847831455fadc1f7e8f4d2d94aef0d5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 10 13:49:46 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 10 14:01:33 2012 +0200

activate: skip manual activation for --sysinit -aay

When --sysinit -a ay is used with vg/lvchange and lvmetad is up and running,
we should skip manual activation as that would be a useless step - all volumes
are autoactivated once all the PVs for a VG are present.

If lvmetad is not active at the time of the vgchange --sysinit -a ay
call, the activation proceeds in standard 'manual' way.

This way, we can still have vg/lvchange --sysinit -a ay called
unconditionally in system initialization scripts no matter if lvmetad
is used or not.
---
 WHATS_NEW         |    1 +
 man/lvchange.8.in |    5 +++++
 man/vgchange.8.in |    5 +++++
 tools/lvchange.c  |    7 +++++++
 tools/vgchange.c  |    7 +++++++
 5 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 02ac14a..9d6f091 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Skip activation when using vg/lvchange --sysinit -a ay and lvmetad is active.
   Fix extending RAID 4/5/6 logical volumes
   Fix test for PV with unknown VG in process_each_pv to ignore ignored mdas.
   Update man pages with --activate ay option and auto_activation_volume_list.
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index c7507d4..bf9ef48 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -105,6 +105,11 @@ this is equivalent to using  \fB\-\-ignorelockingfailure\fP,
 \fB\-\-ignoremonitoring\fP, \fB\-\-poll n\fP and setting
 \fBLVM_SUPPRESS_LOCKING_FAILURE_MESSAGES\fP
 environment variable.
+
+If \fB\-\-sysinit\fP is used in conjunction with lvmetad(8) enabled and running,
+autoactivation is preferred over manual activation via direct lvchange call.
+Logical volumes are autoactivated according to auto_activation_volume_list
+set in lvm.conf(5).
 .TP
 .B \-\-noudevsync
 Disable udev synchronisation. The
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 28e2623..0f5fc58 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -121,6 +121,11 @@ this is equivalent to using
 .B \-\-poll n
 and setting \fBLVM_SUPPRESS_LOCKING_FAILURE_MESSAGES\fP
 environment variable.
+
+If \fB\-\-sysinit\fP is used in conjunction with lvmetad(8) enabled and running,
+autoactivation is preferred over manual activation via direct vgchange call.
+Logical volumes are autoactivated according to auto_activation_volume_list
+set in lvm.conf(5).
 .TP
 .BR \-\-noudevsync
 Disable udev synchronisation. The
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 9876847..9054ac7 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -798,6 +798,13 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, sysinit_ARG) && lvmetad_active() &&
+	    arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY) {
+		log_warn("lvmetad is active while using --sysinit -a ay, "
+			 "skipping manual activation");
+		return ECMD_PROCESSED;
+	}
+
 	return process_each_lv(cmd, argc, argv,
 			       update ? READ_FOR_UPDATE : 0, NULL,
 			       &lvchange_single);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index ebabb08..2013447 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -608,6 +608,13 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, sysinit_ARG) && lvmetad_active() &&
+	    arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY) {
+		log_warn("lvmetad is active while using --sysinit -a ay, "
+			 "skipping manual activation");
+		return ECMD_PROCESSED;
+	}
+
 	return process_each_vg(cmd, argc, argv, update ? READ_FOR_UPDATE : 0,
 			       NULL, &vgchange_single);
 }


