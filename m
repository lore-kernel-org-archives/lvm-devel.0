From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Oct 2013 12:22:57 +0000 (UTC)
Subject: master - udev+systemd: refine lvm2-pvscan@.service to better track device existence
Message-ID: <20131022122257.2967A6108F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3fee6610286f83737d193c9047e24e8d7c85d1ce
Commit:        3fee6610286f83737d193c9047e24e8d7c85d1ce
Parent:        0a48137d39c51163ee29608c8c7ccbeecb4a7815
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 22 14:03:53 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 22 14:22:40 2013 +0200

udev+systemd: refine lvm2-pvscan at .service to better track device existence

When using ENV{SYSTEMD_WANTS}=lvm2-pvscan at ... to instantiate a service
for lvmetad scan when the new PV appears in the system, the service
is started and executed. However, to track device removal, we need
to bind it (the "BindsTo" systemd directive) to a certain .device
systemd unit.

In default systemd setup, the device is tracked by it's name and
sysfs path (there's normally a sysfs path .device systemd unit for
a device and then the device name .device unit as an alias for it).
Neither of these two is useful for lvmetad update as we need to bind
it to device's <major>:<minor> pair.

The /dev/block/<major>:<minor> is the essential symlink under /dev
that exists for each block device (created by default udev rules
provided by udev directly). So let's use this as an alias for
the device's .device unit as well by means of "ENV{SYSTEMD_ALIAS}"
declaration within udev rules which systemd understands (this will
create a new alias "dev-block-<major>:<minor>.device".

Then we can easily bind the "dev-block-<major>:<minor>" device
systemd unit with instantiated lvm2-pvscan@<major>:<minor>.service.
So once the device is removed from the systemd, the
lvm-pvscan@<major>:<minor>.service executes it's ExecStop action
(which in turn notifies lvmetad about the device being gone).

This completes the udev-systemd-lvmetad interaction then.
---
 WHATS_NEW                                       |    1 +
 scripts/lvm2_pvscan_systemd_red_hat at .service.in |   11 +++++++----
 udev/Makefile.in                                |    4 +++-
 3 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index df81923..2d7792b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Add dev-block-<major>:<minor>.device systemd alias for complete PV tracking.
   Use major:minor as short form of --major and --minor arg for pvscan --cache.
   Remove 2>/dev/null from three lvm commands executed by vgimportclone.
   Add configure --enable-udev-systemd-background-jobs.
diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
index 9d91b5e..07ea5ca 100644
--- a/scripts/lvm2_pvscan_systemd_red_hat at .service.in
+++ b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
@@ -1,11 +1,14 @@
 [Unit]
-Description=LVM2 PV scan on %I
+Description=LVM2 PV scan on device %i
 Documentation=man:pvscan(8)
 DefaultDependencies=no
-After=lvm2-lvmetad.socket %i.device
+BindsTo=dev-block-%i.device
+After=lvm2-lvmetad.socket
 Before=shutdown.target
 Conflicts=shutdown.target
 
 [Service]
-Type=simple
-ExecStart=@sbindir@/pvscan --cache --activate ay %I
+Type=oneshot
+RemainAfterExit=yes
+ExecStart=@sbindir@/pvscan --cache --activate ay /dev/block/%i
+ExecStop=/usr/sbin/pvscan --cache %i
diff --git a/udev/Makefile.in b/udev/Makefile.in
index fdf43df..8f0dc8a 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -47,7 +47,9 @@ BLKID_RULE=IMPORT{program}=\"${SBIN}\/blkid -o udev -p \$$tempnode\"
 endif
 
 ifeq ("@UDEV_SYSTEMD_BACKGROUND_JOBS@", "yes")
-PVSCAN_RULE=ENV{SYSTEMD_WANTS}=\"lvm2-pvscan@\$$devnode.service\"
+PVSCAN_RULE="ENV{SYSTEMD_ALIAS}=\"/dev/block/$$major:$$minor\" \
+	     ENV{ID_MODEL}=\"LVM PV $$env{ID_FS_UUID_ENC} on /dev/$$name\" \
+	     ENV{SYSTEMD_WANTS}=\"lvm2-pvscan@\$$devnode.service\""
 else
 PVSCAN_RULE=RUN\+\=\"$(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major \$$major --minor \$$minor\", ENV{LVM_SCANNED}=\"1\"
 endif


