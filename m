From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Oct 2021 21:35:03 +0000 (GMT)
Subject: main - The path is known anyway and should be the bullet proof option.
Message-ID: <20211021213503.BF8CB3857805@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=221e75316f472fbf5eb2ad206b861ea255c099ed
Commit:        221e75316f472fbf5eb2ad206b861ea255c099ed
Parent:        ae355ffc3f3286990778517e1ad6620368611258
Author:        Christian Hesse <mail@eworm.de>
AuthorDate:    Thu Oct 21 16:33:23 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 21 16:33:23 2021 -0500

The path is known anyway and should be the bullet proof option.

Signed-off-by: Christian Hesse <mail@eworm.de>
---
 udev/69-dm-lvm.rules.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/udev/69-dm-lvm.rules.in b/udev/69-dm-lvm.rules.in
index 39e5b9807..d6bf1e0e9 100644
--- a/udev/69-dm-lvm.rules.in
+++ b/udev/69-dm-lvm.rules.in
@@ -80,7 +80,7 @@ ENV{SYSTEMD_READY}="1"
 # it's better suited to appearing in the journal.
 
 IMPORT{program}="(LVM_EXEC)/lvm pvscan --cache --listvg --checkcomplete --vgonline --udevoutput --journal=output $env{DEVNAME}"
-ENV{LVM_VG_NAME_COMPLETE}=="?*", RUN+="/usr/bin/systemd-run -r --no-block --property DefaultDependencies=no --unit lvm-activate-$env{LVM_VG_NAME_COMPLETE} lvm vgchange -aay --nohints $env{LVM_VG_NAME_COMPLETE}"
+ENV{LVM_VG_NAME_COMPLETE}=="?*", RUN+="/usr/bin/systemd-run -r --no-block --property DefaultDependencies=no --unit lvm-activate-$env{LVM_VG_NAME_COMPLETE} (LVM_EXEC)/lvm vgchange -aay --nohints $env{LVM_VG_NAME_COMPLETE}"
 GOTO="lvm_end"
 
 LABEL="lvm_end"


