From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:22:33 -0500
Subject: master - tests: compatible with older kernels
Message-ID: <32218.120020411222000561@us-mta-251.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=62ad12d0d05d8ffa26df4f1b1b6ef3b2113420b1
Commit:        62ad12d0d05d8ffa26df4f1b1b6ef3b2113420b1
Parent:        c0de37ab1888a53cce97007c3f4fdfb6f85ab5bf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 29 15:50:57 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

tests: compatible with older kernels

Older kernels just show syscall stacktrace.
---
 test/shell/dmsecuretest.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/dmsecuretest.sh b/test/shell/dmsecuretest.sh
index 0f53ea7..144b1f4 100644
--- a/test/shell/dmsecuretest.sh
+++ b/test/shell/dmsecuretest.sh
@@ -47,7 +47,7 @@ dmsetup status "$DMTEST"
 # generate core file for running&sleeping binary
 gcore "$PID" | tee out
 # check we capture core while  dmsecuretest was already sleeping
-grep "nanosleep" out
+grep "nanosleep" out || grep kernel_vsyscall out
 kill "$PID" || true
 wait
 



