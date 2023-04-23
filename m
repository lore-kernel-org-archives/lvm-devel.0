From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 23 Apr 2023 11:09:33 +0000 (GMT)
Subject: main - aux: loop doesn't support zeroing discard
Message-ID: <20230423110933.A66E13858C50@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7cf5feb7d245d22d4968b95f3b7cfb6467461ff2
Commit:        7cf5feb7d245d22d4968b95f3b7cfb6467461ff2
Parent:        bbc67abeed8a7a5f4a31c6dd0d3bf4cb26c6a50a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 23 00:02:33 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 23 00:02:33 2023 +0200

aux: loop doesn't support zeroing discard

To avoid logging unsupported WRITE_ZEROES with loop,
disable usage for this backend device.
---
 test/lib/aux.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d6689e3b8..a385df76b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -669,6 +669,7 @@ prepare_loop() {
 		done
 	fi
 	test -n "$LOOP" # confirm or fail
+	touch NO_BLKDISCARD_Z    # loop devices do not support WRITE_ZEROS
 	BACKING_DEV=$LOOP
 	echo "$LOOP" > LOOP
 	echo "$LOOP" > BACKING_DEV

