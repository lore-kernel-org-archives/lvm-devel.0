From: David Teigland <teigland@sourceware.org>
Date: Thu, 13 Sep 2018 12:09:55 -0400
Subject: master - add lvmlocks service to start and stop lockspaces
Message-ID: <201809131609.w8DG9tdq026960@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9b6cdd6e65196d6ada6ce54e8d256c3dc57329b
Commit:        e9b6cdd6e65196d6ada6ce54e8d256c3dc57329b
Parent:        81ca0cb1619b6ea22fa68f54783cd62dafbd2eaf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 13 10:50:50 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 13 10:50:50 2018 -0500

add lvmlocks service to start and stop lockspaces

---
 scripts/lvmlocks.service.in |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/scripts/lvmlocks.service.in b/scripts/lvmlocks.service.in
new file mode 100644
index 0000000..79598db
--- /dev/null
+++ b/scripts/lvmlocks.service.in
@@ -0,0 +1,18 @@
+[Unit]
+Description=LVM locking start and stop
+Documentation=man:lvmlockd(8)
+After=lvm2-lvmlockd.service sanlock.service dlm.service
+
+[Service]
+Type=oneshot
+RemainAfterExit=yes
+
+# start lockspaces and wait for them to finish starting
+ExecStart=@SBINDIR@/lvm vgchange --lock-start --lock-opt autowait
+
+# stop lockspaces and wait for them to finish stopping
+ExecStop=@SBINDIR@/lvmlockctl --stop-lockspaces --wait 1
+
+[Install]
+WantedBy=multi-user.target
+


