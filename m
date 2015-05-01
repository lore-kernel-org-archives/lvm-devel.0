From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:40:21 +0000 (UTC)
Subject: master - tests: free -h is quite new option
Message-ID: <20150501134021.44D9B610ED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c7063ef893449742922a4bcbcbe6c38f191b8dc
Commit:        9c7063ef893449742922a4bcbcbe6c38f191b8dc
Parent:        79844b9066e53d9618f6641d5cee9c7264fe01fd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 1 15:37:50 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:40:04 2015 +0200

tests: free -h is quite new option

Stay with -g and and ignore failure.
---
 test/lib/inittest.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index d5c80f4..98abae6 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -78,7 +78,7 @@ echo "$TESTNAME" >TESTNAME
 echo "Kernel is $(uname -a)"
 # Report SELinux mode
 echo "Selinux mode is $(getenforce 2>/dev/null || echo not installed)."
-free -h
+free -m || true
 
 # Set vars from utils now that we have TESTDIR/PREFIX/...
 prepare_test_vars


