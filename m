From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 20 Oct 2010 16:28:20 +0200
Subject: [PATCH 1/2] Fix compiler warning about strict-aliasing break
In-Reply-To: <cover.1287584556.git.zkabelac@redhat.com>
References: <cover.1287584556.git.zkabelac@redhat.com>
Message-ID: <1b243b9c196c6ce24ded0e088a21c5162be337d2.1287584556.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch not really tested - and just show a possible solution
for strict-alliasing error.

So patch is just a proposal of one of many solution.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/device/device.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/device/device.c b/lib/device/device.c
index 593e642..91eb14c 100644
--- a/lib/device/device.c
+++ b/lib/device/device.c
@@ -58,9 +58,11 @@ static int _has_partition_table(struct device *dev)
 {
 	int ret = 0;
 	unsigned p;
-	uint16_t buf[SECTOR_SIZE/sizeof(uint16_t)];
-	uint16_t *part_magic;
-	struct partition *part;
+	struct {
+		uint8_t skip[PART_OFFSET];
+		struct partition part[4];
+		uint16_t magic;
+	} __attribute__((packed)) buf; /* sizeof() == SECTOR_SIZE */
 
 	if (!dev_read(dev, UINT64_C(0), sizeof(buf), &buf))
 		return_0;
@@ -68,17 +70,15 @@ static int _has_partition_table(struct device *dev)
 	/* FIXME Check for other types of partition table too */
 
 	/* Check for msdos partition table */
-	part_magic = buf + PART_MAGIC_OFFSET/sizeof(buf[0]);
-	if ((*part_magic == xlate16(PART_MAGIC))) {
-		part = (struct partition *) (buf + PART_OFFSET/sizeof(buf[0]));
-		for (p = 0; p < 4; p++, part++) {
+	if (buf.magic == xlate16(PART_MAGIC)) {
+		for (p = 0; p < 4; ++p) {
 			/* Table is invalid if boot indicator not 0 or 0x80 */
-			if ((part->boot_ind & 0x7f)) {
+			if (buf.part[p].boot_ind & 0x7f) {
 				ret = 0;
 				break;
 			}
 			/* Must have at least one non-empty partition */
-			if (part->nr_sects)
+			if (buf.part[p].nr_sects)
 				ret = 1;
 		}
 	}
-- 
1.7.3.1


