From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 17 Feb 2014 15:30:54 +0000 (UTC)
Subject: master - scripts: use --ignoreskippedcluster in lvm2-monitor initscript/systemd unit
Message-ID: <20140217153054.20BA660DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f33a224ef016f2071d7f0f6fdacfe56d98c3c58a
Commit:        f33a224ef016f2071d7f0f6fdacfe56d98c3c58a
Parent:        6e2f70623351fe5de0e8179d377578a08b0a3625
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 17 16:25:32 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 17 16:29:49 2014 +0100

scripts: use --ignoreskippedcluster in lvm2-monitor initscript/systemd unit

When clustered VG is available in the system but we don't have
clustering set up for whatever reason, the lvm2-monitor scripts should
not fail completely just because these clustered VGs are skipped during
vgs/vgchange calls in lvm2-monitor initscript/systemd unit.
---
 WHATS_NEW                                          |    1 +
 scripts/lvm2_monitoring_init_red_hat.in            |    8 ++++----
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    4 ++--
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 17b79ba..c02fcae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Use --ignoreskippedcluster in lvm2-monitor initscript/systemd unit.
   Do not use VG read/write state for LV read/write state.
   Use --ignoreskippedcluster in activation systemd units if use_lvmetad=0.
   Allow approximate allocation when specifying size in percentage terms.
diff --git a/scripts/lvm2_monitoring_init_red_hat.in b/scripts/lvm2_monitoring_init_red_hat.in
index cae652c..44de07f 100644
--- a/scripts/lvm2_monitoring_init_red_hat.in
+++ b/scripts/lvm2_monitoring_init_red_hat.in
@@ -48,10 +48,10 @@ start()
 {
 	ret=0
 	# TODO do we want to separate out already active groups only?
-	VGSLIST=`$VGS --noheadings -o name --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
+	VGSLIST=`$VGS --noheadings -o name --ignoreskippedcluster --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGSLIST
 	do
-	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y --poll y --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
+	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y --poll y --ignoreskippedcluster --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
 	done
 
 	return $ret
@@ -66,10 +66,10 @@ stop()
 	   echo "Not stopping monitoring, this is a dangerous operation. Please use force-stop to override."
 	   return 1
 	fi
-	VGSLIST=`$VGS --noheadings -o name --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
+	VGSLIST=`$VGS --noheadings -o name --ignoreskippedcluster --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGSLIST
 	do
-	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
+	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n --ignoreskippedcluster --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
 	done
 	return $ret
 }
diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index 670d0c4..05f911b 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -10,9 +10,9 @@ Conflicts=shutdown.target
 [Service]
 Type=oneshot
 Environment=LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
-ExecStart=@sbindir@/lvm vgchange --monitor y
+ExecStart=@sbindir@/lvm vgchange --monitor y --ignoreskippedcluster
 # The lvmetad must be disabled here, it needs https://bugzilla.redhat.com/show_bug.cgi?id=843587 to be resolved first.
-ExecStop=@sbindir@/lvm vgchange --monitor n --config 'global{use_lvmetad=0}'
+ExecStop=@sbindir@/lvm vgchange --monitor n --config 'global{use_lvmetad=0}' --ignoreskippedcluster
 RemainAfterExit=yes
 
 [Install]


