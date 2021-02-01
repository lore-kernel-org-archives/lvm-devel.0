From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 13:38:29 +0000 (GMT)
Subject: stable-2.02 - aux: update thin_restore_needs_more_volumes
Message-ID: <20210201133829.AA3C3382E071@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=18677e24c1ab6e9dff36c048d9e3f6a7fe541c4b
Commit:        18677e24c1ab6e9dff36c048d9e3f6a7fe541c4b
Parent:        99bdbc53ba391e1f58833d0bdf3df935ce6f73f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 22 20:17:57 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 14:35:53 2021 +0100

aux: update thin_restore_needs_more_volumes

Version 0.8.5-2.el7 needs to return 0;
---
 test/lib/aux.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 728e6dc0e..4b303474a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1509,6 +1509,7 @@ thin_restore_needs_more_volumes() {
 	case $("$LVM_TEST_THIN_RESTORE_CMD" -V) in
 		# With older version of thin-tool we got slightly more compact metadata
 		0.[0-6]*|0.7.0*) return 0 ;;
+		0.8.5-2.el7) return 0 ;;
 	esac
 	return 1
 }


