From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jun 2023 16:01:54 +0000 (GMT)
Subject: main - vdo: fix and enhance vdo metadata reader
Message-ID: <20230609160154.9E7A93858C41@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=00633f8b668d94a58756d96f5927fd690b8f41d3
Commit:        00633f8b668d94a58756d96f5927fd690b8f41d3
Parent:        fcf2057b3824ab461ad43821101d09f2b06dcac8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 13:21:35 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 18:01:16 2023 +0200

vdo: fix and enhance vdo metadata reader

Improve metadata parser to handle volume_geometry bio_offset,
which needs to be substracted from 'region' start_block when present.

This bio_offset block is non-zero i.e. with converted VDO volumes.

Also fix some converted structure value (but they are not in use).
---
 device_mapper/vdo/vdo_reader.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/device_mapper/vdo/vdo_reader.c b/device_mapper/vdo/vdo_reader.c
index 9f1344f4b..de8677c79 100644
--- a/device_mapper/vdo/vdo_reader.c
+++ b/device_mapper/vdo/vdo_reader.c
@@ -146,13 +146,14 @@ static void _vdo_decode_header(struct vdo_header *h)
 static void _vdo_decode_geometry_region(struct vdo_volume_region *vr)
 {
 	vr->id = le32_to_cpu(vr->id);
-	vr->start_block = le32_to_cpu(vr->start_block);
+	vr->start_block = le64_to_cpu(vr->start_block);
 }
 
 static void _vdo_decode_volume_geometry(struct vdo_volume_geometry *vg)
 {
-	vg->release_version = le64_to_cpu(vg->release_version);
+	vg->release_version = le32_to_cpu(vg->release_version);
 	vg->nonce = le64_to_cpu(vg->nonce);
+	vg->bio_offset = le64_to_cpu(vg->bio_offset);
 	_vdo_decode_geometry_region(&vg->regions[VDO_DATA_REGION]);
 }
 
@@ -224,10 +225,14 @@ bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 		goto err;
 	}
 
+	if (h.id != 5) {
+		log_debug_activation("Expected geometry VDO block instead of block %u.", h.id);
+		goto err;
+	}
 	memcpy(&vg, buffer + MAGIC_NUMBER_SIZE + sizeof(h), sizeof(vg));
 	_vdo_decode_volume_geometry(&vg);
 
-	regpos = vg.regions[VDO_DATA_REGION].start_block * 4096;
+	regpos = (vg.regions[VDO_DATA_REGION].start_block - vg.bio_offset) * 4096;
 
 	if ((regpos + sizeof(buffer)) > size) {
 		log_debug_activation("File/Device is shorter and can't provide requested VDO volume region at " FMTu64 " > " FMTu64 ".", regpos, size);
@@ -244,7 +249,6 @@ bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 		goto err;
 	}
 
-
 	memcpy(&vn, buffer + sizeof(struct vdo_geometry_block), sizeof(vn));
 	_vdo_decode_version(&vn);
 

