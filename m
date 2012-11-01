From: Ondrej Kozina <okozina@redhat.com>
Date: Thu,  1 Nov 2012 18:22:15 +0100
Subject: [PATCH 1/3] - add clvmd native systemd service
In-Reply-To: <1351790537-10199-1-git-send-email-okozina@redhat.com>
References: <1351790537-10199-1-git-send-email-okozina@redhat.com>
Message-ID: <1351790537-10199-2-git-send-email-okozina@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

just a few notes:

RefuseManualStop - we don't want user to stop the daemon w/o proper deactivation
RefuseManualStart - I can remove that, but right now I don't see any reason to allow it
StopWhenUnneeded - when all direct dependecies are gone, we can finish 

---
 scripts/clvmd_systemd_red_hat.service.in | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)
 create mode 100644 scripts/clvmd_systemd_red_hat.service.in

diff --git a/scripts/clvmd_systemd_red_hat.service.in b/scripts/clvmd_systemd_red_hat.service.in
new file mode 100644
index 0000000..d141721
--- /dev/null
+++ b/scripts/clvmd_systemd_red_hat.service.in
@@ -0,0 +1,20 @@
+[Unit]
+Description=Clustered LVM daemon
+Documentation=man:clvmd(8)
+After=network.target dlm.service corosync.service
+Before=remote-fs.target
+RefuseManualStart=true
+RefuseManualStop=true
+StopWhenUnneeded=true
+
+[Service]
+Type=forking
+Environment=CLVMD_OPTS=-T30
+EnvironmentFile=- at sysconfdir@/etc/sysconfig/clvmd
+ExecStart=@sbindir@/clvmd $CLVMD_OPTS
+ExecReload=@sbindir@/clvmd -R
+SuccessExitStatus=5
+TimeoutStartSec=30
+TimeoutStopSec=10
+OOMScoreAdjust=-1000
+Restart=on-abort
-- 
1.7.12.4


