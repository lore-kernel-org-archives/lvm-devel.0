From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Nov 2022 10:10:37 +0000 (GMT)
Subject: main - vdo: replace errors with debug
Message-ID: <20221108101037.D6F5D3858427@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=218c7d44b5ac64b6c38dfd40885a22008b5cec81
Commit:        218c7d44b5ac64b6c38dfd40885a22008b5cec81
Parent:        c98617c593a84e32ff8ee32ecf2382d4e1369c16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 4 16:27:56 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 8 11:07:20 2022 +0100

vdo: replace errors with debug

As we actully use reading of VDO metadata only as extra 'information' source,
and not error command - switch to 'log_debug()' severity with messages
out of parser code.
---
 device_mapper/vdo/vdo_reader.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/device_mapper/vdo/vdo_reader.c b/device_mapper/vdo/vdo_reader.c
index b765af042..4f91f8011 100644
--- a/device_mapper/vdo/vdo_reader.c
+++ b/device_mapper/vdo/vdo_reader.c
@@ -188,19 +188,19 @@ bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 
 	*logical_blocks = 0;
 	if ((fh = open(vdo_path, O_RDONLY)) == -1) {
-		log_sys_error("Failed to open VDO backend %s", vdo_path);
+		log_sys_debug("Failed to open VDO backend %s.", vdo_path);
 		goto err;
 	}
 
 	if (ioctl(fh, BLKGETSIZE64, &size) == -1) {
 		if (errno != ENOTTY) {
-			log_sys_error("ioctl", vdo_path);
+			log_sys_debug("ioctl", vdo_path);
 			goto err;
 		}
 
 		/* lets retry for file sizes */
 		if (fstat(fh, &st) < 0) {
-			log_sys_error("fstat", vdo_path);
+			log_sys_debug("fstat", vdo_path);
 			goto err;
 		}
 
@@ -208,12 +208,12 @@ bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 	}
 
 	if ((n = read(fh, buffer, sizeof(buffer))) < 0) {
-		log_sys_error("read", vdo_path);
+		log_sys_debug("read", vdo_path);
 		goto err;
 	}
 
 	if (strncmp(buffer, _MAGIC_NUMBER, MAGIC_NUMBER_SIZE)) {
-		log_sys_error("mismatch header", vdo_path);
+		log_debug_activation("Found mismatching VDO magic header in %s.", vdo_path);
 		goto err;
 	}
 
@@ -221,7 +221,7 @@ bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 	_vdo_decode_header(&h);
 
 	if  (h.version.major_version != 5) {
-		log_error("Unsupported VDO version %u.%u.", h.version.major_version, h.version.minor_version);
+		log_debug_activation("Unsupported VDO version %u.%u.", h.version.major_version, h.version.minor_version);
 		goto err;
 	}
 
@@ -231,17 +231,17 @@ bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 	regpos = vg.regions[VDO_DATA_REGION].start_block * 4096;
 
 	if ((regpos + sizeof(buffer)) > size) {
-		log_error("File/Device is shorter and can't provide requested VDO volume region at " FMTu64 " > " FMTu64 ".", regpos, size);
+		log_debug_activation("File/Device is shorter and can't provide requested VDO volume region at " FMTu64 " > " FMTu64 ".", regpos, size);
 		goto err;
 	}
 
 	if ((l = lseek(fh, regpos, SEEK_SET)) < 0) {
-		log_sys_error("lseek", vdo_path);
+		log_sys_debug("lseek", vdo_path);
 		goto err;
 	}
 
 	if ((n = read(fh, buffer, sizeof(buffer))) < 0) {
-		log_sys_error("read error", vdo_path);
+		log_sys_debug("read", vdo_path);
 		goto err;
 	}
 
@@ -250,7 +250,7 @@ bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 	_vdo_decode_version(&vn);
 
 	if (vn.major_version > 41) {
-		log_error("Unknown VDO component version %u.", vn.major_version); // should be 41!
+		log_debug_activation("Unknown VDO component version %u.", vn.major_version); // should be 41!
 		goto err;
 	}
 
@@ -258,16 +258,16 @@ bool dm_vdo_parse_logical_size(const char *vdo_path, uint64_t *logical_blocks)
 	_vdo_decode_pvc(&pvc);
 
 	if (pvc.nonce != vg.nonce) {
-		log_error("Mismatching VDO nonce " FMTu64 " != " FMTu64 ".", pvc.nonce, vg.nonce);
+		log_debug_activation("VDO metadata has mismatching VDO nonces " FMTu64 " != " FMTu64 ".", pvc.nonce, vg.nonce);
 		goto err;
 	}
 
 #if 0
-	log_debug("LogBlocks    " FMTu64 ".", pvc.config.logical_blocks);
-	log_debug("PhyBlocks    " FMTu64 ".", pvc.config.physical_blocks);
-	log_debug("SlabSize     " FMTu64 ".", pvc.config.slab_size);
-	log_debug("RecJourSize  " FMTu64 ".", pvc.config.recovery_journal_size);
-	log_debug("SlabJouSize  " FMTu64 ".", pvc.config.slab_journal_blocks);
+	log_debug_activation("LogBlocks    " FMTu64 ".", pvc.config.logical_blocks);
+	log_debug_activation("PhyBlocks    " FMTu64 ".", pvc.config.physical_blocks);
+	log_debug_activation("SlabSize     " FMTu64 ".", pvc.config.slab_size);
+	log_debug_activation("RecJourSize  " FMTu64 ".", pvc.config.recovery_journal_size);
+	log_debug_activation("SlabJouSize  " FMTu64 ".", pvc.config.slab_journal_blocks);
 #endif
 
 	*logical_blocks = pvc.config.logical_blocks;

