From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 27 Feb 2015 14:46:55 +0000 (UTC)
Subject: master - initscripts: lvm2-monitor: use @DMEVENTD_PIDFILE@ instead of hardcoded /var/run/dmeventd.pid
Message-ID: <20150227144655.C671F60045@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e09f8a82f19dde6ab56a678e7ba289a658445080
Commit:        e09f8a82f19dde6ab56a678e7ba289a658445080
Parent:        57e9e76da4a678957e2db07a4b6b5f75385d4539
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 27 15:48:10 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 27 15:48:10 2015 +0100

initscripts: lvm2-monitor: use @DMEVENTD_PIDFILE@ instead of hardcoded /var/run/dmeventd.pid

---
 scripts/lvm2_monitoring_init_red_hat.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_monitoring_init_red_hat.in b/scripts/lvm2_monitoring_init_red_hat.in
index 90b6edc..7c5e805 100644
--- a/scripts/lvm2_monitoring_init_red_hat.in
+++ b/scripts/lvm2_monitoring_init_red_hat.in
@@ -42,7 +42,7 @@ VGS=${sbindir}/vgs
 LVS=${sbindir}/lvs
 
 LOCK_FILE="/var/lock/subsys/$DAEMON"
-PID_FILE="/var/run/dmeventd.pid"
+PID_FILE="@DMEVENTD_PIDFILE@"
 
 WARN=1
 export LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1


