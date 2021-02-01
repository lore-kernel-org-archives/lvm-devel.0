From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:46 +0000 (GMT)
Subject: main - aux: update thin_restore_needs_more_volumes
Message-ID: <20210201114746.82C983836C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25b942a8acd35c44ea39ff1840d8c4af0bed12d6
Commit:        25b942a8acd35c44ea39ff1840d8c4af0bed12d6
Parent:        b26e565ee5d27314a58cba31e0a017d927698440
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 22 20:17:57 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:13:49 2021 +0100

aux: update thin_restore_needs_more_volumes

Version 0.8.5-2.el7 needs to return 0;
---
 test/lib/aux.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5dbb580be..31741ac74 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1471,6 +1471,7 @@ thin_restore_needs_more_volumes() {
 	case $("$LVM_TEST_THIN_RESTORE_CMD" -V) in
 		# With older version of thin-tool we got slightly more compact metadata
 		0.[0-6]*|0.7.0*) return 0 ;;
+		0.8.5-2.el7) return 0 ;;
 	esac
 	return 1
 }


