From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 17:39:06 -0400
Subject: master - tests: restore functionality
Message-ID: <201805122139.w4CLd6Gx005410@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=093428b067d751f9a6d645d430bfff6fd3031acd
Commit:        093428b067d751f9a6d645d430bfff6fd3031acd
Parent:        7b8b13c62b5407a9959bad2168c0c7dadfc80981
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 22:51:43 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 22:51:43 2018 +0200

tests: restore functionality

Forgotten revert of tracing patch. Restoring previous functinality.
---
 test/shell/fsadm-crypt.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 68959e3..77bda35 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -123,8 +123,7 @@ check_missing()
 }
 
 get_crypt_kname() {
-	lsblk -r -n -o KNAME,NAME | tee out
-	grep "$1" out | cut -d ' ' -f 1
+	lsblk -r -n -o KNAME,NAME | grep "$1" | cut -d ' ' -f 1
 }
 
 


