From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 4 Jul 2019 07:06:18 -0400
Subject: master - udev: do not overwrite ID_MODEL in 69-dm-lvm-metad.rules
Message-ID: <201907041106.x64B6I4W005665@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fef8e506891bd159475de83f248fdac660675163
Commit:        fef8e506891bd159475de83f248fdac660675163
Parent:        f938545687accd8f451b1bde806484301e0ae086
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 4 12:57:55 2019 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 4 12:57:55 2019 +0200

udev: do not overwrite ID_MODEL in 69-dm-lvm-metad.rules

We've been assigning this in 69-dm-lvm-metad.rules:

  ENV{ID_MODEL}="LVM PV $env{ID_FS_UUID_ENC} on /dev/$name"

This was for the description to appear for each systemd device
unit representing this device, for example:

  $systemctl -a | grep "LVM PV"
  dev-block-252:2.device                                                                                         loaded    active   plugged   LVM PV JhxC7B-YTgk-3jIU-5GVo-c4gV-W8t3-UUz06p on /dev/vda2 2
  dev-disk-by\x2did-lvm\x2dpv\x2duuid\x2dJhxC7B\x2dYTgk\x2d3jIU\x2d5GVo\x2dc4gV\x2dW8t3\x2dUUz06p.device         loaded    active   plugged   LVM PV JhxC7B-YTgk-3jIU-5GVo-c4gV-W8t3-UUz06p on /dev/vda2 2
  ...

However, there could be an actual ID_MODEL that people are interested in
more than the fact that this is an LVM PV and so we shouldn't overwrite
the value.

Also, we already have a symlink /dev/disk/by-id/lvm-pv-uuid-<PV_UUID>
created which is then reflected as device unit (all device's symlinks
have systemd device unit representation) so we can still reach this
information in systemd unit listings even without setting the ID_MODEL.

Reported here: https://github.com/lvmteam/lvm2/issues/21
---
 udev/69-dm-lvm-metad.rules.in |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 2ff8ddc..d510064 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -110,7 +110,6 @@ LABEL="systemd_background"
 #  other |    X     |      X      |       X        |                   |   X
 ACTION!="remove", ENV{LVM_PV_GONE}=="1", RUN+="(BINDIR)/systemd-run (LVM_EXEC)/lvm pvscan --cache $major:$minor", GOTO="lvm_end"
 ENV{SYSTEMD_ALIAS}="/dev/block/$major:$minor"
-ENV{ID_MODEL}="LVM PV $env{ID_FS_UUID_ENC} on /dev/$name"
 ENV{SYSTEMD_WANTS}+="lvm2-pvscan@$major:$minor.service"
 GOTO="lvm_end"
 


