From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:40 +0000 (UTC)
Subject: master - test: Remove spurious set -x in lvm-wrapper.
Message-ID: <20150205134340.4FC4D60079@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=78ba413ed148f34a36e2e041947e66a681255d0d
Commit:        78ba413ed148f34a36e2e041947e66a681255d0d
Parent:        d8983d4bd4c76381c8bd9149c942b83cd8d013b4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 11:50:31 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:06 2015 +0100

test: Remove spurious set -x in lvm-wrapper.

---
 test/lib/lvm-wrapper.sh |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index 496facc..8bc96a2 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -31,8 +31,6 @@ if test -n "$LVM_STRACE"; then
 	RUN_DBG="strace $LVM_STRACE -o strace.log"
 fi
 
-set -x
-
 case "$CMD" in
   lvs|pvs|vgs|vgck|vgscan)
 	test ${LVM_DEBUG_LEVEL:-0} -lt 2 && RUN_DBG= ;;


