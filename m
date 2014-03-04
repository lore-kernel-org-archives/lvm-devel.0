From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Mar 2014 15:27:53 +0000 (UTC)
Subject: master - tests: print kernel version
Message-ID: <20140304152753.B9D0B6184A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a01e2ff81c9e7f629d9011b7d69d9f2780a98484
Commit:        a01e2ff81c9e7f629d9011b7d69d9f2780a98484
Parent:        b47bdb4dca6eda577206aa76b83697524111d046
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 4 16:24:44 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 4 16:27:00 2014 +0100

tests: print kernel version

---
 test/lib/test.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/test.sh b/test/lib/test.sh
index 3dc0dfb..d7f6111 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -67,6 +67,7 @@ export DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
 
 echo "$TESTNAME" >TESTNAME
 
+echo "Kernel is $(uname -a)"
 # Report SELinux mode
 if which getenforce &>/dev/null ; then
 	echo "Selinux mode is \"$(getenforce 2>/dev/null)\"."


