From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 May 2019 15:25:44 -0400
Subject: master - tests: hints check if strace exists
Message-ID: <201905211925.x4LJPiIf004110@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99ca06ca4662ac43c09fb423bb26451ae5171d86
Commit:        99ca06ca4662ac43c09fb423bb26451ae5171d86
Parent:        dc1e12dcd423cf912489e1ed380fa6eb1a049f2e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 21 14:23:01 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 21 14:24:57 2019 -0500

tests: hints check if strace exists

avoid test failure if test system does not
have strace
---
 test/shell/hints.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index 31628b0..019912e 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -53,12 +53,15 @@ grep -v -E "$dev1|$dev2" $HINTS > tmptest
 not grep scan: tmptest
 
 # test that 'pvs' submits only two reads, one for each PV in hints
+
+if [ -e "/usr/bin/strace" ]; then
 strace -e io_submit pvs 2>&1|tee tmptest
 test "$(grep io_submit tmptest | wc -l)" -eq 2
 
 # test that 'pvs -a' submits six reads, one for each device
 strace -e io_submit pvs -a 2>&1|tee tmptest
 test "$(grep io_submit tmptest | wc -l)" -eq 6
+fi
 
 #
 # vg2 uses dev3,dev4


