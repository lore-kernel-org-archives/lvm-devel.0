From: David Teigland <teigland@sourceware.org>
Date: Tue, 14 Dec 2021 17:59:51 +0000 (GMT)
Subject: main - udev: remove -r from systemd-run
Message-ID: <20211214175951.BA5563858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fbd8b0cf43dc67f51f86f060dce748f446985855
Commit:        fbd8b0cf43dc67f51f86f060dce748f446985855
Parent:        6a431eb24241caf2277d3e5b4718782d92650a2a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 14 11:57:13 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 14 11:57:13 2021 -0600

udev: remove -r from systemd-run

If the transient service remains after it's done, then
it prevents the same transient service from being run
again later if the PVs are detached and reattached
(although the behavior of a second autoactivation is not
well defined and may only work in limited cases.)
---
 udev/69-dm-lvm.rules.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/udev/69-dm-lvm.rules.in b/udev/69-dm-lvm.rules.in
index 4f34b2cc2..14e7dd26d 100644
--- a/udev/69-dm-lvm.rules.in
+++ b/udev/69-dm-lvm.rules.in
@@ -80,7 +80,7 @@ ENV{SYSTEMD_READY}="1"
 # it's better suited to appearing in the journal.
 
 IMPORT{program}="(LVM_EXEC)/lvm pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output $env{DEVNAME}"
-ENV{LVM_VG_NAME_COMPLETE}=="?*", RUN+="/usr/bin/systemd-run -r --no-block --property DefaultDependencies=no --unit lvm-activate-$env{LVM_VG_NAME_COMPLETE} (LVM_EXEC)/lvm vgchange -aay --autoactivation event $env{LVM_VG_NAME_COMPLETE}"
+ENV{LVM_VG_NAME_COMPLETE}=="?*", RUN+="/usr/bin/systemd-run --no-block --property DefaultDependencies=no --unit lvm-activate-$env{LVM_VG_NAME_COMPLETE} (LVM_EXEC)/lvm vgchange -aay --autoactivation event $env{LVM_VG_NAME_COMPLETE}"
 GOTO="lvm_end"
 
 LABEL="lvm_end"


