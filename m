From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 28 Nov 2013 13:12:39 +0000 (UTC)
Subject: master - tests: wipe fs signature manually in pvcreate-operation test
Message-ID: <20131128131239.6209860994@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08bab406b5bcae92df340209c1a0902e68aa1a28
Commit:        08bab406b5bcae92df340209c1a0902e68aa1a28
Parent:        c24b558c8c3e8f877e7cf216369e3415be8dbc6f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 28 14:10:55 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 28 14:10:55 2013 +0100

tests: wipe fs signature manually in pvcreate-operation test

So that the next pvcreate that is called does not issue any
warnings/prompts about existing signature (when blkid wiping is used).
---
 test/shell/pvcreate-operation.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index ddcf94c..b885ed2 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -23,6 +23,9 @@ do
 		not pvcreate -M$mdatype "$dev1" 2>err
 		grep "Can't open "$dev1" exclusively.  Mounted filesystem?" err
 		umount "$dev1"
+		# wipe the filesystem signature for next
+		# pvcreate to not issue any prompts
+		dd if=/dev/zero of=$dev1 bs=1K count=2
 	fi
 
 # pvcreate (lvm$mdatype) succeeds when run repeatedly (pv not in a vg) (bz178216)


