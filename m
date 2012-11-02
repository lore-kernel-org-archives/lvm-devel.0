From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  2 Nov 2012 19:34:17 +0000 (UTC)
Subject: master - systemd: remove quotes in lvm2-monitor.service ExecStop
Message-ID: <20121102193417.5DD21A2C51@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c7672b3c0916b3cee8aec90f90275a1320acc70
Commit:        7c7672b3c0916b3cee8aec90f90275a1320acc70
Parent:        aa07de5a50175a2cee3f8662a23544d43feaf128
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Nov 2 20:32:28 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Nov 2 20:32:28 2012 +0100

systemd: remove quotes in lvm2-monitor.service ExecStop

---
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index 3cb998b..670d0c4 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -12,7 +12,7 @@ Type=oneshot
 Environment=LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
 ExecStart=@sbindir@/lvm vgchange --monitor y
 # The lvmetad must be disabled here, it needs https://bugzilla.redhat.com/show_bug.cgi?id=843587 to be resolved first.
-ExecStop="@sbindir@/lvm vgchange --monitor n --config 'global{use_lvmetad=0}'"
+ExecStop=@sbindir@/lvm vgchange --monitor n --config 'global{use_lvmetad=0}'
 RemainAfterExit=yes
 
 [Install]


