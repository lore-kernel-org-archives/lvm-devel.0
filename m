From: David Teigland <teigland@sourceware.org>
Date: Tue, 10 Jul 2018 15:20:18 -0400
Subject: master - tests: fix mkdir pvs_online
Message-ID: <201807101920.w6AJKIf9019298@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=edf3f86184a380994e383b9884364e702e4ac647
Commit:        edf3f86184a380994e383b9884364e702e4ac647
Parent:        06439a256217b5d37ef33833051fc322a58b4859
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 10 14:19:46 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 10 14:19:46 2018 -0500

tests: fix mkdir pvs_online

---
 test/shell/pvscan-autoactivate.sh |    2 ++
 test/shell/pvscan-nomda-bg.sh     |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index af6f2b2..85a08cf 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -19,6 +19,8 @@ aux prepare_pvs 2
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 -a n $vg1
 
+mkdir /run/lvm/pvs_online || true
+
 # the first pvscan scans all devs 
 
 rm /run/lvm/pvs_online/*
diff --git a/test/shell/pvscan-nomda-bg.sh b/test/shell/pvscan-nomda-bg.sh
index f8ecc08..d73f3da 100644
--- a/test/shell/pvscan-nomda-bg.sh
+++ b/test/shell/pvscan-nomda-bg.sh
@@ -26,7 +26,7 @@ check inactive $vg1 foo
 
 # create a file in pvs_online to disable the pvscan init
 # case which scans everything when the first dev appears.
-mkdir /run/lvm/pvs_online/
+mkdir /run/lvm/pvs_online || true
 touch /run/lvm/pvs_online/foo
 
 pvscan --cache --background "$dev2" -aay


