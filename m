From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Oct 2013 13:29:04 +0000 (UTC)
Subject: master - udev: wrong line in previous commit
Message-ID: <20131030132904.B078C61427@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de7531d384b1b505801ac232da45b9ffe58f061b
Commit:        de7531d384b1b505801ac232da45b9ffe58f061b
Parent:        f070e3543a411d483b7c34b6ea8e6e8e0cc35edf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 30 14:28:43 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 30 14:28:43 2013 +0100

udev: wrong line in previous commit

---
 udev/69-dm-lvm-metad.rules.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 8ea5c92..5b15b6f 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -51,6 +51,7 @@ KERNEL!="md[0-9]*", GOTO="next"
 IMPORT{db}="LVM_MD_PV_ACTIVATED"
 ACTION=="add", ENV{LVM_MD_PV_ACTIVATED}=="1", GOTO="lvm_scan"
 ACTION=="change", ENV{LVM_MD_PV_ACTIVATED}!="1", TEST=="md/array_state", ENV{LVM_MD_PV_ACTIVATED}="1", GOTO="lvm_scan"
+ACTION=="add", KERNEL=="md[0-9]*p[0-9]*", GOTO="lvm_scan"
 GOTO="lvm_end"
 
 # Loop device:
@@ -58,7 +59,6 @@ LABEL="next"
 KERNEL!="loop[0-9]*", GOTO="next"
 ACTION=="add", ENV{LVM_LOOP_PV_ACTIVATED}=="1", GOTO="lvm_scan"
 ACTION=="change", ENV{LVM_LOOP_PV_ACTIVATED}!="1", TEST=="loop/backing_file", ENV{LVM_LOOP_PV_ACTIVATED}="1", GOTO="lvm_scan"
-ACTION=="add", KERNEL=="md[0-9]*p[0-9]*", GOTO="lvm_scan"
 GOTO="lvm_end"
 
 # If the PV is not a special device listed above, scan only after device addition (ADD event)


