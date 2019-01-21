From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:56 -0500
Subject: master - tests: aux fix testing for kvdo
Message-ID: <201901211155.x0LBtuev024566@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=246b0c444bfcea68fe6c6d7174e753ee08dd7d8f
Commit:        246b0c444bfcea68fe6c6d7174e753ee08dd7d8f
Parent:        2cac4bfc150ea1e5459580e3bac4907446ea7f3a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 20 12:15:20 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

tests: aux fix testing for kvdo

---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a11eb3f..1e8f0de 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1410,6 +1410,7 @@ version_at_least() {
 target_at_least() {
 	rm -f debug.log strace.log
 	case "$1" in
+	  dm-vdo) modprobe "kvdo" || true ;;
 	  dm-*) modprobe "$1" || true ;;
 	esac
 


