From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:24 +0000 (UTC)
Subject: master - tests: more coverage
Message-ID: <20140317133324.7F2B860EAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=404593c710678082f7ff16efdfd1fe5394fb1bba
Commit:        404593c710678082f7ff16efdfd1fe5394fb1bba
Parent:        7d3fa6fc32c1922d621a7a87ab81c0dc08679b10
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 16 23:47:18 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:44 2014 +0100

tests: more coverage

---
 test/shell/covercmd.sh |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index f9a04e9..ca45c2f 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -30,7 +30,7 @@ lvcreate -l 5 -i5 -I256 -n $lv $vg
 if aux have_readline; then
 # test *scan and *display tools
 cat <<EOF | lvm
-pvscan
+pvscan --uuid
 vgscan
 lvscan
 lvmdiskscan
@@ -47,7 +47,7 @@ for i in h b s k m g t p e H B S K M G T P E; do
 	echo pvdisplay --units $i "$dev1"
 done | lvm
 else
-pvscan
+pvscan --uuid
 vgscan
 lvscan
 lvmdiskscan
@@ -85,6 +85,7 @@ done
 
 pvck "$dev1"
 vgck $vg
+vgs -o all $vg
 lvrename $vg $lv $lv-rename
 vgcfgbackup -f backup.$$ $vg
 vgchange -an $vg


