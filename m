From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  5 Mar 2014 13:33:52 +0000 (UTC)
Subject: master - udev: run pvscan --cache via systemd-run in udev if the PV label is detected lost
Message-ID: <20140305133352.E5F5860F98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c42f608904a853328341eac3cfd3c48033a3238
Commit:        2c42f608904a853328341eac3cfd3c48033a3238
Parent:        3c9887467f3c33d5ea10503c74ad85c4b119d3df
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 5 14:25:08 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 5 14:30:58 2014 +0100

udev: run pvscan --cache via systemd-run in udev if the PV label is detected lost

If the PV label is lost (e.g. by doing a dd on the device), call
"systemd-run pvscan --cache <major>:<minor>" in 69-dm-lvm-metad.rules
to inform lvmetad about this state.

The reason for this is that ENV{SYSTEMD_WANTS}="lvm2-pvscan@<major>:<minor>"
logic will not cause the pvscan to be fired in this case since this works
only on proper device addition/removal cycle - the lvm2-pvscan service's
ExecStop is called only on proper REMOVE event - the service is bound to
device existence. Hence we need pvscan call via systemd-run (that
instantiates a quick transient service just to call the command).

See also https://bugzilla.redhat.com/show_bug.cgi?id=1063813.
---
 WHATS_NEW        |    1 +
 udev/Makefile.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8b5f31a..7deba2f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Run pvscan --cache via systemd-run in udev if the PV label is detected lost.
   Fix memleak when lvmetad discovers PV to appear on another device.
   Fix calculation of maximum size of COW device for snapshot (2.02.99).
   Do not allow stripe size to be bigger then extent size for lvresize.
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 40a4671..a2e2571 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -47,7 +47,7 @@ BLKID_RULE=IMPORT{program}=\"${SBIN}\/blkid -o udev -p \$$tempnode\"
 endif
 
 ifeq ("@UDEV_SYSTEMD_BACKGROUND_JOBS@", "yes")
-PVSCAN_RULE=ENV{SYSTEMD_ALIAS}=\"\/dev\/block\/\$$major:\$$minor\"\nENV{ID_MODEL}=\"LVM PV \$$env{ID_FS_UUID_ENC} on \/dev\/\$$name\"\nENV{SYSTEMD_WANTS}=\"lvm2-pvscan@\$$major:\$$minor.service\"
+PVSCAN_RULE=ACTION\!=\"remove\", ENV{LVM_PV_GONE}==\"1\", RUN\+=\"@bindir@/systemd-run $(LVM_EXEC)\/lvm pvscan --cache \$$major\:\$$minor\", GOTO=\"lvm_end\"\nENV{SYSTEMD_ALIAS}=\"\/dev\/block\/\$$major:\$$minor\"\nENV{ID_MODEL}=\"LVM PV \$$env{ID_FS_UUID_ENC} on \/dev\/\$$name\"\nENV{SYSTEMD_WANTS}=\"lvm2-pvscan@\$$major:\$$minor.service\"
 else
 PVSCAN_RULE=RUN\+\=\"$(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major \$$major --minor \$$minor\", ENV{LVM_SCANNED}=\"1\"
 endif


