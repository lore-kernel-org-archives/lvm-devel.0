From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 16 Aug 2013 13:51:01 +0000 (UTC)
Subject: master - udev: fix lvmetad rules to not ignore loop device configuration
Message-ID: <20130816135101.CAF81600ED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cac49725c9a2a1f5c0e48235a07f168d98458ace
Commit:        cac49725c9a2a1f5c0e48235a07f168d98458ace
Parent:        f1dc4d3d81456d506b2c56fb2e8b12106cbd9e16
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 16 15:45:00 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 16 15:45:00 2013 +0200

udev: fix lvmetad rules to not ignore loop device configuration

If loop device is first configured on systems where /dev/loop-control
is used to dynamically create the loop device itself, there's an
ADD+CHANGE even generated. But next time the existing /dev/loop[0-9]*
is reused, there's only a CHANGE event since the device representing
it is already present in kernel (so no ADD event in this case).

We can't ignore this CHANGE event for loop devices! This is a regression
caused by 756bcabbfe297688ba240a880bc2b55265ad33f0. We already had
a similar problem with MD devices which was fixed by
2ac217d408470dcecb69b83d9cbf7a254747fa5b (but that one was
only an intra-release fix).
---
 WHATS_NEW                     |    1 +
 udev/69-dm-lvm-metad.rules.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a4df6c9..3cf3e47 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Fix ignored lvmetad update on loop device configuration (2.02.99).
   Use LVM_PATH instead of hardcoded value in lvm2 activation systemd generator.
   Refresh existing VG before autoactivation (event retrigger/device reappeared).
   Fix vgck to notice on-disk corruption even if lvmetad is used.
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index a0e48a1..d5087e3 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -21,7 +21,7 @@ SUBSYSTEM!="block", GOTO="lvm_end"
 ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_end"
 
 ACTION=="remove", GOTO="lvm_scan"
-ACTION=="change", KERNEL=="md[0-9]*", GOTO="lvm_scan"
+ACTION=="change", KERNEL=="md[0-9]*|loop[0-9]*", GOTO="lvm_scan"
 
 # If the PV is not a dm device, scan only after device addition (ADD event)
 KERNEL!="dm-[0-9]*", ACTION!="add", GOTO="lvm_end"


