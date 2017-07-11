From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 11:22:12 -0400
Subject: master - cleanup: whitespace
Message-ID: <201707111522.v6BFMCw0015452@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2c3d9a07cbaa49275d24c40c6a4fa2480b1ac3d8
Commit:        2c3d9a07cbaa49275d24c40c6a4fa2480b1ac3d8
Parent:        3cd492cd599262872b212a4fc9eefc7050ce1517
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 11 11:21:18 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 11 16:26:12 2017 +0200

cleanup: whitespace

---
 lib/misc/crc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/misc/crc.c b/lib/misc/crc.c
index fc4d3f0..aacd82d 100644
--- a/lib/misc/crc.c
+++ b/lib/misc/crc.c
@@ -63,7 +63,7 @@ static uint32_t _calc_crc_new(uint32_t initial, const uint8_t *buf, uint32_t siz
 	const uint32_t *start = (const uint32_t *) buf;
 	const uint32_t *end = (const uint32_t *) (buf + (size & 0xfffffffc));
 	uint32_t crc = initial;
-   
+
 	/* Process 4 bytes per iteration */
 	while (start < end) {
 		crc = crc ^ xlate32(*start++);


