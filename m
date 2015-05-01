From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:08:25 +0000 (UTC)
Subject: master - tests: watch out for RAM size
Message-ID: <20150501130825.4390860366@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f48a4c391c2f7f92765f6608a60e79b008ead890
Commit:        f48a4c391c2f7f92765f6608a60e79b008ead890
Parent:        11e0dc40dcae9021bb52d60403fd1a3b8b40c58c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 30 11:55:38 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:07:58 2015 +0200

tests: watch out for RAM size

Reduce mem-requirements on low memory boxes,
activate less volumes if machine is below 0.5G.

Also print mem size at test header.
---
 test/lib/aux.sh             |    7 +++++++
 test/lib/inittest.sh        |    1 +
 test/shell/vgchange-many.sh |    2 ++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 67df0f5..6fceb68 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1066,6 +1066,13 @@ wait_pvmove_lv_ready() {
 	done
 }
 
+# return total memory size in kB units
+total_mem() {
+	while IFS=":" read -r a b ; do
+		case "$a" in MemTotal*) echo ${b%% kB} ; break ;; esac
+	done < /proc/meminfo
+}
+
 test -z "$LVM_TEST_AUX_TRACE" || set -x
 
 test -f DEVICES && devs=$(< DEVICES)
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 96dfff2..dd4f060 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -78,6 +78,7 @@ echo "$TESTNAME" >TESTNAME
 echo "Kernel is $(uname -a)"
 # Report SELinux mode
 echo "Selinux mode is $(getenforce 2>/dev/null || echo not installed)."
+free -h
 
 # Set vars from utils now that we have TESTDIR/PREFIX/...
 prepare_test_vars
diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index 16e0516..cbb4363 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -16,6 +16,8 @@
 
 # Number of LVs to create
 DEVICES=1000
+# On low-memory boxes let's not stress too much
+test "$(aux total_mem)" -gt 524288 || DEVICES=256
 
 aux prepare_pvs 1 400
 


