From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 19 Nov 2014 15:07:26 +0000 (UTC)
Subject: master - systemd: clvmd and cmirrord systemd unit - use usrsbindir instead of sbindir
Message-ID: <20141119150726.A4311610FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a52a9212cc5d3ae90196776f28dbfb319002c74
Commit:        4a52a9212cc5d3ae90196776f28dbfb319002c74
Parent:        7639eae8919e5872143562db8118d039f5a41225
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 19 16:03:11 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 19 16:06:05 2014 +0100

systemd: clvmd and cmirrord systemd unit - use usrsbindir instead of sbindir

---
 scripts/lvm2_clvmd_systemd_red_hat.service.in    |    2 +-
 scripts/lvm2_cmirrord_systemd_red_hat.service.in |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/lvm2_clvmd_systemd_red_hat.service.in b/scripts/lvm2_clvmd_systemd_red_hat.service.in
index 2978d21..2da5114 100644
--- a/scripts/lvm2_clvmd_systemd_red_hat.service.in
+++ b/scripts/lvm2_clvmd_systemd_red_hat.service.in
@@ -14,7 +14,7 @@ Conflicts=shutdown.target
 Type=forking
 Environment=CLVMD_OPTS=-T30
 EnvironmentFile=- at sysconfdir@/sysconfig/clvmd
-ExecStart=@sbindir@/clvmd $CLVMD_OPTS
+ExecStart=@usrsbindir@/clvmd $CLVMD_OPTS
 SuccessExitStatus=5
 TimeoutStartSec=30
 TimeoutStopSec=10
diff --git a/scripts/lvm2_cmirrord_systemd_red_hat.service.in b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
index 16d38ce..e3bf62d 100644
--- a/scripts/lvm2_cmirrord_systemd_red_hat.service.in
+++ b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
@@ -9,7 +9,7 @@ Conflicts=shutdown.target
 
 [Service]
 Type=forking
-ExecStart=@sbindir@/cmirrord
+ExecStart=@usrsbindir@/cmirrord
 PIDFile=@CMIRRORD_PIDFILE@
 Restart=on-abort
 


