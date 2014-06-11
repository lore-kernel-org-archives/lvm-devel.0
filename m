From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Jun 2014 09:07:41 +0000 (UTC)
Subject: master - tests: some more renames lib/test -> lib/inittest
Message-ID: <20140611090741.4BADF60D47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6766cdc8a1a0fb2cd041f629d8c2b6adbaca0ff0
Commit:        6766cdc8a1a0fb2cd041f629d8c2b6adbaca0ff0
Parent:        5c5177c37c88cc0e7d5fbd5b82647ce562dad32f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 11 11:07:32 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 11 11:07:32 2014 +0200

tests: some more renames lib/test -> lib/inittest

---
 test/api/lvtest.sh       |    2 +-
 test/api/pe_start.sh     |    2 +-
 test/api/percent.sh      |    2 +-
 test/api/pytest.sh       |    2 +-
 test/api/thin_percent.sh |    2 +-
 test/api/vglist.sh       |    2 +-
 test/api/vgtest.sh       |    2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/test/api/lvtest.sh b/test/api/lvtest.sh
index 0b7684a..5fe6f57 100644
--- a/test/api/lvtest.sh
+++ b/test/api/lvtest.sh
@@ -11,7 +11,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 1
 
diff --git a/test/api/pe_start.sh b/test/api/pe_start.sh
index 20ba8ec..2fc118f 100644
--- a/test/api/pe_start.sh
+++ b/test/api/pe_start.sh
@@ -11,7 +11,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 2
 
diff --git a/test/api/percent.sh b/test/api/percent.sh
index 097cad8..a503ca3 100644
--- a/test/api/percent.sh
+++ b/test/api/percent.sh
@@ -11,7 +11,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
-. lib/test
+. lib/inittest
 
 kernel_at_least 2 6 33 || skip
 
diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 8359c01..7b6085f 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -11,7 +11,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
-. lib/test
+. lib/inittest
 
 #
 # TODO:
diff --git a/test/api/thin_percent.sh b/test/api/thin_percent.sh
index 50ad8f6..5335655 100644
--- a/test/api/thin_percent.sh
+++ b/test/api/thin_percent.sh
@@ -11,7 +11,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
-. lib/test
+. lib/inittest
 
 aux have_thin 1 0 0 || skip
 
diff --git a/test/api/vglist.sh b/test/api/vglist.sh
index 275c9d2..421705b 100644
--- a/test/api/vglist.sh
+++ b/test/api/vglist.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 2
 aux apitest vglist $vg `get vg_field $vg vg_uuid | sed -e s,-,,g`
diff --git a/test/api/vgtest.sh b/test/api/vgtest.sh
index 6c0be4e..72255fe 100644
--- a/test/api/vgtest.sh
+++ b/test/api/vgtest.sh
@@ -13,7 +13,7 @@
 # tests lvm2app library
 #
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 2
 


