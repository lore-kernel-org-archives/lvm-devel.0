From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Tue, 13 Aug 2019 09:27:13 -0400
Subject: master - udev: remove unsupported OPTIONS+="event_timeout" rule
Message-ID: <201908131327.x7DDRD1c004123@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=125f27ac37bc9b93cc96f64052b9681b3d479ee1
Commit:        125f27ac37bc9b93cc96f64052b9681b3d479ee1
Parent:        e653f43732fd61f8dc272b157f323663abce3daa
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 13 15:18:30 2019 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 13 15:18:30 2019 +0200

udev: remove unsupported OPTIONS+="event_timeout" rule

The OPTIONS+="event_timeout" is Unsupported since systemd/udev version 216,
that is ~5 years ago.

Since systemd/udev version 243, there's a new message printed if unsupported
OPTIONS value is used:

  Invalid value for OPTIONS key, ignoring: 'event_timeout=180'

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1740666
---
 WHATS_NEW               |    1 +
 udev/11-dm-lvm.rules.in |    2 --
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a7ccd39..63c3c27 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Remove unsupported OPTIONS+="event_timeout" udev rule from 11-dm-lvm.rules.
   Prevent creating VGs with PVs with different logical block sizes.
   Fix metadata writes from corrupting with large physical block size.
 
diff --git a/udev/11-dm-lvm.rules.in b/udev/11-dm-lvm.rules.in
index 91cb991..7c58994 100644
--- a/udev/11-dm-lvm.rules.in
+++ b/udev/11-dm-lvm.rules.in
@@ -37,8 +37,6 @@ ENV{DM_SUBSYSTEM_UDEV_FLAG0}!="1", ENV{DM_NOSCAN}=="1", ENV{DM_UDEV_DISABLE_OTHE
 
 ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
 
-OPTIONS+="event_timeout=180"
-
 # Do not create symlinks for inappropriate subdevices.
 ENV{DM_LV_NAME}=="pvmove?*|?*_vorigin", GOTO="lvm_disable"
 ENV{DM_LV_LAYER}=="?*", GOTO="lvm_disable"


