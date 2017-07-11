From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 19:52:21 -0400
Subject: master - tests: bounds still more vars
Message-ID: <201707112352.v6BNqLCd014740@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f2dccc60176dffcf98fdd69734e3e1309095aeb
Commit:        0f2dccc60176dffcf98fdd69734e3e1309095aeb
Parent:        ec9b845aaa6f155fc30951e7f479327402e287f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 12 01:37:29 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 12 01:37:29 2017 +0200

tests: bounds still more vars

---
 test/api/pytest.sh                  |    2 +-
 test/shell/inconsistent-metadata.sh |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index e4e0994..ea53dbd 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -43,7 +43,7 @@ if [[ -n "$abs_top_builddir" ]]; then
     fi
   fi
 
-  PYTHONPATH=$(dirname "${python_lib[*]}"):$PYTHONPATH
+  PYTHONPATH=$(dirname "${python_lib[*]}"):${PYTHONPATH-}
   export PYTHONPATH
 elif rpm -q lvm2-python-libs &>/dev/null; then
   true
diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index 36d7038..358ffcb 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -32,6 +32,7 @@ init() {
 }
 
 # vgscan fixes up metadata (needs --cache option for direct scan if lvmetad is used)
+cache=""
 test -e LOCAL_LVMETAD && cache="--cache"
 init
 vgscan $cache 2>&1 | tee cmd.out


