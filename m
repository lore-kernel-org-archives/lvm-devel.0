From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Jun 2017 06:46:48 -0400
Subject: master - fsadm: restore no answer
Message-ID: <201706191046.v5JAkmbT025203@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c212b8a43750ea48b9e96da75c1349682c81454
Commit:        1c212b8a43750ea48b9e96da75c1349682c81454
Parent:        915d20d0e64e8bf7a91f01c21cb8c30428ddb1e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 19 12:37:40 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 19 12:40:03 2017 +0200

fsadm: restore no answer

Commit 1fe4f80e45a6bfcceed5aaab97fc0e27dfcf2b88 in current version
introduced regression for a terminal user, as he could not enter 'n'
as answer. Add missing break for this case (No whats_new).
---
 scripts/fsadm.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index ea14efe..adf9b55 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -402,6 +402,7 @@ yes_no() {
 	while read -r -s -n 1 ANS ; do
 		case "$ANS" in
 		 "y" | "Y" ) echo y ; return 0 ;;
+		 "n" | "N") break ;;
 		 "" ) if [ -t 1 ] ; then
 			echo y ; return 0
 		      fi ;;


