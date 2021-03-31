From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:08 +0000 (GMT)
Subject: dev-next - fsadm: fix condition when using --getsize64
Message-ID: <20210331214908.AD2C53858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=63c58d2a5d935cd78c77f3db13a655e68fb36367
Commit:        63c58d2a5d935cd78c77f3db13a655e68fb36367
Parent:        9684e82cc44cfec66f30b807160c19c06df2a2d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 24 16:11:55 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 24 16:34:34 2021 +0100

fsadm: fix condition when using --getsize64

When blocksize --getsize64 gives empty result we want to fallback
to ancient  --getsize * --getss  calculation (RHBZ #1942486).

Reported by: ajschorr at alumni.princeton.edu
---
 scripts/fsadm.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index d98833c3a..20ae57462 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -378,7 +378,7 @@ detect_mounted() {
 detect_device_size() {
 	# check if blockdev supports getsize64
 	DEVSIZE=$("$BLOCKDEV" --getsize64 "$VOLUME" 2>"$NULL" || true)
-	if test -n "$DEVSIZE" ; then
+	if test -z "$DEVSIZE" ; then
 		DEVSIZE=$("$BLOCKDEV" --getsize "$VOLUME" || true)
 		test -n "$DEVSIZE" || error "Cannot read size of device \"$VOLUME\"."
 		SSSIZE=$("$BLOCKDEV" --getss "$VOLUME" || true)


