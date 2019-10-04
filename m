From: David Teigland <teigland@sourceware.org>
Date: Fri, 4 Oct 2019 12:08:05 -0400
Subject: master - tests: improve lib wipefs_a
Message-ID: <201910041608.x94G85HO032563@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a22729a5577689d896ea13a82e6af7f7dde30412
Commit:        a22729a5577689d896ea13a82e6af7f7dde30412
Parent:        414f903cdc161e553100af6ad03e68fbf94617c3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 4 11:04:44 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 4 11:06:38 2019 -0500

tests: improve lib wipefs_a

in wipefs fallback, use limited dd and mdadm --zero-superblock
to avoid writing to entire dev in case dev space is provisioned
on write.
---
 test/lib/aux.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 8ceb5db..36e1c2b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -804,7 +804,8 @@ wipefs_a() {
 	if wipefs -V >/dev/null; then
 		wipefs -a "$dev"
 	else
-		dd if=/dev/zero of="$dev" bs=1024 || true
+		dd if=/dev/zero of="$dev" bs=4096 count=8 || true
+		mdadm --zero-superblock "$dev" || true
 	fi
 }
 


