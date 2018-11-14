From: David Teigland <teigland@sourceware.org>
Date: Wed, 14 Nov 2018 11:01:12 -0500
Subject: master - man: pvscan updates
Message-ID: <201811141601.wAEG1Cht029201@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=814cff0c20158b89592bac437faa375d7d8ff682
Commit:        814cff0c20158b89592bac437faa375d7d8ff682
Parent:        819b469880e9f6b18e76d3f1cdbd3e69fe5dab3e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 14 09:34:30 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 14 09:34:30 2018 -0600

man: pvscan updates

---
 man/pvscan.8_des |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/man/pvscan.8_des b/man/pvscan.8_des
index 5e24855..f685b82 100644
--- a/man/pvscan.8_des
+++ b/man/pvscan.8_des
@@ -1,13 +1,11 @@
-pvscan reads all supported LVM block devices in the system for PVs.
-
 When called without the --cache option, pvscan lists PVs on the system,
 like
 .BR pvs (8)
 or
 .BR pvdisplay (8).
 
-When the --cache and -aay options are used, pvscan keeps track of PVs that
-have appeared on the system, and activates LVs in completed VGs.  A VG is
+When the --cache and -aay options are used, pvscan records which PVs are
+available on the system, and activates LVs in completed VGs.  A VG is
 complete when pvscan sees that the final PV in the VG has appeared.  This
 is used by event-based system startup (systemd, udev) to activate LVs.
 
@@ -23,14 +21,14 @@ In most cases, the pvscan will only read the named devices.
 .B pvscan --cache -aay
 .IR device ...
 
-This begins by performing the same steps as above.  If the device is the
-final PV in the VG to appear on the system, then pvscan will activate LVs
-in the VG (the same as vgchange -aay vgname would do.)
+This begins by performing the same steps as above.  Afterward, if the VG
+for the specified PV is complete, then pvscan will activate LVs in the VG
+(the same as vgchange -aay vgname would do.)
 
 .B pvscan --cache
 
-This clears all existing PV online records, then scans all the devices on
-the system, adding PV online records for any PVs that it finds.
+This first clears all existing PV online records, then scans all devices
+on the system, adding PV online records for any PVs that are found.
 
 .B pvscan --cache -aay
 


