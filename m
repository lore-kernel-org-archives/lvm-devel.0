From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:43 +0000 (GMT)
Subject: main - cov: make more obvious buffer is zero ended
Message-ID: <20210927165743.183AE385840F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=27eef1b96402abaadbd328d8912f3ccce96df5e2
Commit:        27eef1b96402abaadbd328d8912f3ccce96df5e2
Parent:        3a3aabb8326c3ccfb9266663b538b9769ebccf28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 14:25:40 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:13 2021 +0200

cov: make more obvious buffer is zero ended

---
 tools/pvck.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index b96b1c784..5273da63c 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -901,7 +901,7 @@ static int _dump_current_text(struct device *dev, struct devicefile *def,
 	int ri = rlocn_index; /* 0 or 1 */
 	int bad = 0;
 
-	if (!(meta_buf = zalloc(meta_size + 1))) {
+	if (!(meta_buf = malloc(meta_size + 1))) {
 		log_print("CHECK: mda_header_%d.raw_locn[%d] no mem for metadata text size %llu", mn, ri,
 			  (unsigned long long)meta_size);
 		return 0;
@@ -947,6 +947,7 @@ static int _dump_current_text(struct device *dev, struct devicefile *def,
 		}
 	}
 
+	meta_buf[meta_size] = 0;
 	crc = calc_crc(INITIAL_CRC, (uint8_t *)meta_buf, meta_size);
 	if (crc != meta_checksum) {
 		log_print("CHECK: metadata text at %llu crc does not match mda_header_%d.raw_locn[%d].checksum",


