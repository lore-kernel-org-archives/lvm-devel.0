From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:27 +0000 (UTC)
Subject: master - tests: check for python before other tests
Message-ID: <20140224201727.4353B60EBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc839fb3610a344d6c392a09995e44e6dbfac545
Commit:        dc839fb3610a344d6c392a09995e44e6dbfac545
Parent:        32138969f9f8bd4e33e2b9131ac67db061d75f70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 24 10:51:10 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:13:36 2014 +0100

tests: check for python before other tests

---
 test/api/pytest.sh |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index a0f9a2f..8359c01 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -20,19 +20,20 @@
 # Until fixed - testing always runs with enabled monitoring
 # thus it needs dmeventd
 #
-aux prepare_dmeventd
-test ! -e LOCAL_CLVMD || skip
-test ! -e LOCAL_LVMETAD || skip
-
-#If you change this change the unit test case too.
-aux prepare_pvs 6
 
 #Locate the python binding library to use.
 python_lib=$(find $abs_top_builddir -name lvm.so)
-
 # Unable to test python bindings if library not available
 test -n "$python_lib" || skip
 
+test -e LOCAL_CLVMD && skip
+test -e LOCAL_LVMETAD && skip
+
+aux prepare_dmeventd
+
+#If you change this change the unit test case too.
+aux prepare_pvs 6
+
 export PYTHONPATH=$(dirname $python_lib):$PYTHONPATH
 
 #Setup which devices the unit test can use.


