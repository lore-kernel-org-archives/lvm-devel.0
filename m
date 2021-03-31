From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:09 +0000 (GMT)
Subject: dev-next - fsadm: handle error from blkid
Message-ID: <20210331214909.CFEB43857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=28865f971e0b23f4d1a4117e0e0fdb61bd21d836
Commit:        28865f971e0b23f4d1a4117e0e0fdb61bd21d836
Parent:        63c58d2a5d935cd78c77f3db13a655e68fb36367
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 24 16:26:17 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 24 16:37:09 2021 +0100

fsadm: handle error from blkid

Fsadm wants to print its own error message when it can't detect
type of the filesystem on a block device.
Otherwise fsadm exits with no message on an unused block device.
---
 scripts/fsadm.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 20ae57462..3e1f3d405 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -230,7 +230,7 @@ detect_fs() {
 	esac
 	# use null device as cache file to be sure about the result
 	# not using option '-o value' to be compatible with older version of blkid
-	FSTYPE=$("$BLKID" -c "$NULL" -s TYPE "$VOLUME")
+	FSTYPE=$("$BLKID" -c "$NULL" -s TYPE "$VOLUME" || true)
 	test -n "$FSTYPE" || error "Cannot get FSTYPE of \"$VOLUME\"."
 	FSTYPE=${FSTYPE##*TYPE=\"} # cut quotation marks
 	FSTYPE=${FSTYPE%%\"*}


