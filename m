From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:28 +0200
Subject: [PATCH 21/30] Fix constness warning
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <5d5357eeae2459f9109434742ce9af32120427d5.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/misc/crc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/misc/crc.c b/lib/misc/crc.c
index f2f2f06..9f95c37 100644
--- a/lib/misc/crc.c
+++ b/lib/misc/crc.c
@@ -59,8 +59,8 @@ static uint32_t _calc_crc_new(uint32_t initial, const uint8_t *buf, uint32_t siz
 		0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf,
 		0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94, 0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d,
 	};
-	uint32_t *start = (uint32_t *) buf;
-	uint32_t *end = (uint32_t *) (buf + (size & 0xfffffffc));
+	const uint32_t *start = (const uint32_t *) buf;
+	const uint32_t *end = (const uint32_t *) (buf + (size & 0xfffffffc));
 	uint32_t crc = initial;
    
 	/* Process 4 bytes per iteration */
@@ -73,7 +73,7 @@ static uint32_t _calc_crc_new(uint32_t initial, const uint8_t *buf, uint32_t siz
 	}
 
 	/* Process any bytes left over */
-	buf = (uint8_t *) start;
+	buf = (const uint8_t *) start;
 	size = size & 0x3;
 	while (size--) {
 		crc = crc ^ *buf++;
-- 
1.7.3.1


