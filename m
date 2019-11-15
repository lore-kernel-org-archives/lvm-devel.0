From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Nov 2019 06:38:42 -0500
Subject: master - tests: add more tracing info
Message-ID: <67570.119111506383300189@us-mta-341.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f88f7c0fdcdfbefa37df6adb36a637526bd7e93b
Commit:        f88f7c0fdcdfbefa37df6adb36a637526bd7e93b
Parent:        496c368528c20b02d12be19b8fe359b9f0c2cea6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 15 12:37:13 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 12:37:44 2019 +0100

tests: add more tracing info

---
 test/shell/nomda-missing.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/nomda-missing.sh b/test/shell/nomda-missing.sh
index dd57867..1899f03 100644
--- a/test/shell/nomda-missing.sh
+++ b/test/shell/nomda-missing.sh
@@ -74,6 +74,8 @@ check active $vg mirror12
 vgchange -a n $vg
 aux enable_dev "$dev3"
 aux disable_dev "$dev4"
+dmsetup table
+dmsetup info -c
 vgchange -aey $vg
 not vgck $vg
 



