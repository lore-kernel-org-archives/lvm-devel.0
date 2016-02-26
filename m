From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 26 Feb 2016 09:22:44 +0000 (UTC)
Subject: master - dbus: fix the systemd service providing the DBus service
Message-ID: <20160226092244.7A08560DAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e31f5186904328d7f3fc8eae71cda72715107e7
Commit:        3e31f5186904328d7f3fc8eae71cda72715107e7
Parent:        88530b2ef34527eae2bacc86c765fb680f5b6b2b
Author:        Vratislav Podzimek <vpodzime@redhat.com>
AuthorDate:    Thu Feb 25 16:34:41 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 26 10:20:08 2016 +0100

dbus: fix the systemd service providing the DBus service

Correct name is lvm2-lvmdbusd.service not lvmdbusd.service.
This makes the bus-activation (auto-activation) work.

Signed-off-by: Vratislav Podzimek <vpodzime@redhat.com>
---
 WHATS_NEW                              |    1 +
 scripts/com.redhat.lvmdbus1.service.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 250f3f1..ecae780 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.144 - 
 =====================================
+  Fix SystemdService lvm2-lvmdbusd.service name.
   Improve support for env LVM_VG_NAME for reference VG name in lvconvert.
   Fix regresion when lvresize accepted zero sizes (2.02.141).
   Always warn user about PV in use even when pvremove uses --force --force.
diff --git a/scripts/com.redhat.lvmdbus1.service.in b/scripts/com.redhat.lvmdbus1.service.in
index e271b08..5578ed1 100644
--- a/scripts/com.redhat.lvmdbus1.service.in
+++ b/scripts/com.redhat.lvmdbus1.service.in
@@ -2,4 +2,4 @@
 Name=com.redhat.lvmdbus1
 Exec=@sbindir@/lvmdbusd --udev
 User=root
-SystemdService=lvmdbusd.service
+SystemdService=lvm2-lvmdbusd.service


