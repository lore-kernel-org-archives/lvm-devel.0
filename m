From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 20:53:18 +0000 (UTC)
Subject: master - tests: checking mirror_remove_missing
Message-ID: <20140520205318.C75D7601FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b57b4db88940566cb7df9368eb5520ebab1634a2
Commit:        b57b4db88940566cb7df9368eb5520ebab1634a2
Parent:        f919a255b7875db0049eb71e10a2638842541415
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 22:50:52 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 22:50:52 2014 +0200

tests: checking mirror_remove_missing

FIXME:

Seems like conversion of log is not supported in clustered VG
and needs to be fixed.
---
 test/shell/lvconvert-repair-replace.sh |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 53c0938..c02d2ac 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -51,10 +51,15 @@ check mirror $vg 2way
 aux enable_dev "$dev1" "$dev2"
 vgremove -ff $vg
 
+# FIXME  - exclusive activation for mirrors should work here
+# conversion of inactive cluster logs is also unsupported
+test -e LOCAL_CLVMD && exit 0
+
+
 # Test repair of inactive mirror with log failure
 #  Replacement should fail, but convert should succeed (switch to corelog)
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -aey --type mirror -m 2 --ignoremonitoring --nosync -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
+lvcreate -aey --type mirror -m 2 --ignoremonitoring -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 vgchange -a n $vg
 pvremove -ff -y "$dev4"
 lvconvert -y --repair $vg/mirror2
@@ -62,9 +67,6 @@ check mirror $vg mirror2
 vgs $vg
 vgremove -ff $vg
 
-# FIXME  - exclusive activation for mirrors should work here
-test -e LOCAL_CLVMD && exit 0
-
 if kernel_at_least 3 0 0; then
 	# 2-way, mirrored log
 	# Double log failure, full replace


