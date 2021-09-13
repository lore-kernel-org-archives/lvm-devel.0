From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:00 +0000 (GMT)
Subject: main - vdo: prompt with no return failure
Message-ID: <20210913103600.333443858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b24c0fe4e197383101eae53b14f19586cf2eda1
Commit:        3b24c0fe4e197383101eae53b14f19586cf2eda1
Parent:        812653d59806439379d80bb8124f6962ae42d46a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 10 22:39:23 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

vdo: prompt with no return failure

Exit 1  (failure) when prompt for conversion is answered as 'No'.
---
 scripts/lvm_import_vdo.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index a72056721..06cdb106d 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -356,7 +356,7 @@ EOF
 		read -n 1 -s ANSWER
 		case "${ANSWER:0:1}" in
 			y|Y )  echo "Yes" ;;
-			* )    echo "No" ; PROMPTING=""; exit ;;
+			* )    echo "No" ; PROMPTING=""; exit 1 ;;
 		esac
 		PROMPTING=""
 		YES="-y" # From now, now prompting


