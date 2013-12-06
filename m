From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Dec 2013 09:40:07 +0000 (UTC)
Subject: master - tests: more limits for python test
Message-ID: <20131206094007.20BCC60DD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b3adf4eea7cba080ff907012715aac66bf807a3
Commit:        2b3adf4eea7cba080ff907012715aac66bf807a3
Parent:        f460d6d9b5dcf0e13b70d4c1630a0f667849b8b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 6 10:37:49 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 6 10:37:49 2013 +0100

tests: more limits for python test

It will be most probably more problem with
incomplete initialization of lvm.conf settings
when lvm2app is in use.

Skip cluster & lvmetad test for now.
---
 test/api/pytest.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 55df9e8..a0f9a2f 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -21,6 +21,8 @@
 # thus it needs dmeventd
 #
 aux prepare_dmeventd
+test ! -e LOCAL_CLVMD || skip
+test ! -e LOCAL_LVMETAD || skip
 
 #If you change this change the unit test case too.
 aux prepare_pvs 6
@@ -29,7 +31,7 @@ aux prepare_pvs 6
 python_lib=$(find $abs_top_builddir -name lvm.so)
 
 # Unable to test python bindings if library not available
-test -z "$python_lib" && skip
+test -n "$python_lib" || skip
 
 export PYTHONPATH=$(dirname $python_lib):$PYTHONPATH
 


