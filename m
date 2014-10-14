From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 14 Oct 2014 08:08:46 +0000 (UTC)
Subject: master - systemd: remove workaround for lvm2-monitor.service's ExecStop line
Message-ID: <20141014080846.6835560572@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=02628413ca99648e70e38406384be69e20a2a6ce
Commit:        02628413ca99648e70e38406384be69e20a2a6ce
Parent:        d1bcdd7338148a887aae44149e3ea756c1df17a3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 14 09:56:58 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 14 10:08:23 2014 +0200

systemd: remove workaround for lvm2-monitor.service's ExecStop line

Bug https://bugzilla.redhat.com/show_bug.cgi?id=843587 is handled better
now - the hang does not occur anymore. There are still error messages
issued though during shutdown if someone stops lvm2-lvmetad.service
manually that lvm2-monitor.service depends on (even during shutdown).
These errors are correct though and will point to incorrect
configuration (still having use_lvmetad=1 in lvm.conf and stopping
lvm2-lvmetad.service manually).

The workaround to prevent the hang is not needed now. So the
'--config "global{use_lvmetad=0}"' is now removed from the
lvm2-monitor.service's ExecStop line.
---
 WHATS_NEW                                          |    1 +
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8511a45..2a0adf4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Remove workaround for lvm2-monitor.service hang on stop if lvmetad stopped.
   Change vgremove to use process_each_lv_in_vg.
   Introduce WARN_ flags to control some metadata warning messages.
   Use process_each_pv in vgreduce.
diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index 05f911b..bb52f0d 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -11,8 +11,7 @@ Conflicts=shutdown.target
 Type=oneshot
 Environment=LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
 ExecStart=@sbindir@/lvm vgchange --monitor y --ignoreskippedcluster
-# The lvmetad must be disabled here, it needs https://bugzilla.redhat.com/show_bug.cgi?id=843587 to be resolved first.
-ExecStop=@sbindir@/lvm vgchange --monitor n --config 'global{use_lvmetad=0}' --ignoreskippedcluster
+ExecStop=@sbindir@/lvm vgchange --monitor n --ignoreskippedcluster
 RemainAfterExit=yes
 
 [Install]


