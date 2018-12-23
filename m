From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 22 Dec 2018 19:12:51 -0500
Subject: master - tests: testing mirrorred mirror log
Message-ID: <201812230012.wBN0CpUe005387@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1dee4b4ffcbc4324316718edbe464bbeb98a17db
Commit:        1dee4b4ffcbc4324316718edbe464bbeb98a17db
Parent:        88faf5a53b34cdfe2d4932a6800af8530f8f5396
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 23 01:06:16 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 23 01:07:05 2018 +0100

tests: testing mirrorred mirror log

Enable mirrorlog creation for test.
---
 test/shell/lvconvert-mirror-basic.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 8166613..96d30d2 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+aux lvmconf "global/support_mirrored_mirror_log=1"
+
 log_name_to_count() {
 	case "$1"  in
 	mirrored) echo 2 ;;


