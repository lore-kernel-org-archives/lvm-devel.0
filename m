From: Mikulas Patocka <mpatocka@redhat.com>
Date: Thu, 29 Aug 2019 11:52:13 -0400 (EDT)
Subject: [PATCH] blkid: retport block size of a filesystem
Message-ID: <alpine.LRH.2.02.1908291142470.17653@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch extends libblkid, so that it reports filesystem block size.

When blkid returns a specific number in the BLOCK_SIZE attribute, it 
guarantees that all the bios submitted by the filesystem are aligned on 
this boundary.

We need this because when we want to enable dm-integrity or dm-writecache 
on an existing filesystem, we need to know filesystem block size, so that 
dm-integrity or dm-writecache is initialized with matching block size.

We could always use block size 512 for dm-integrity and dm-writecache, but
that would cause metadata overhead and performance degradation. On the
other hand, if we used block size 4096, it would fail if the filesystem
has smaller blocksize.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 libblkid/src/superblocks/apfs.c        |    2 
 libblkid/src/superblocks/befs.c        |    3 +
 libblkid/src/superblocks/btrfs.c       |    1 
 libblkid/src/superblocks/exfat.c       |    2 
 libblkid/src/superblocks/exfs.c        |    4 +
 libblkid/src/superblocks/ext.c         |    3 +
 libblkid/src/superblocks/f2fs.c        |    2 
 libblkid/src/superblocks/gfs.c         |    1 
 libblkid/src/superblocks/hfs.c         |    2 
 libblkid/src/superblocks/hpfs.c        |    1 
 libblkid/src/superblocks/iso9660.c     |    2 
 libblkid/src/superblocks/jfs.c         |    1 
 libblkid/src/superblocks/minix.c       |    5 ++
 libblkid/src/superblocks/nilfs.c       |    3 +
 libblkid/src/superblocks/ntfs.c        |    2 
 libblkid/src/superblocks/ocfs.c        |    3 +
 libblkid/src/superblocks/reiserfs.c    |   10 +++-
 libblkid/src/superblocks/romfs.c       |    3 +
 libblkid/src/superblocks/squashfs.c    |    2 
 libblkid/src/superblocks/superblocks.c |    7 +++
 libblkid/src/superblocks/superblocks.h |    2 
 libblkid/src/superblocks/udf.c         |    2 
 libblkid/src/superblocks/ufs.c         |    5 ++
 libblkid/src/superblocks/vfat.c        |    2 
 libblkid/src/superblocks/vxfs.c        |   18 +++++++
 libblkid/src/superblocks/xfs.c         |    1 
 libblkid/src/superblocks/zfs.c         |   76 ++++++++++++++++++++++++---------
 27 files changed, 144 insertions(+), 21 deletions(-)

Index: util-linux/libblkid/src/superblocks/ext.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/ext.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/ext.c	2019-08-29 15:44:56.000000000 +0200
@@ -187,6 +187,9 @@ static void ext_get_info(blkid_probe pr,
 	blkid_probe_sprintf_version(pr, "%u.%u",
 		le32_to_cpu(es->s_rev_level),
 		le16_to_cpu(es->s_minor_rev_level));
+
+	if (le32_to_cpu(es->s_log_block_size) < 32)
+		blkid_probe_set_block_size(pr, 1024U << le32_to_cpu(es->s_log_block_size));
 }
 
 
Index: util-linux/libblkid/src/superblocks/superblocks.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/superblocks.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/superblocks.c	2019-08-29 15:44:38.000000000 +0200
@@ -74,6 +74,8 @@
  * @APPLICATION_ID: ISO9660 application identifier
  *
  * @BOOT_SYSTEM_ID: ISO9660 boot system identifier
+ *
+ * @BLOCK_SIZE: block size
  */
 
 static int superblocks_probe(blkid_probe pr, struct blkid_chain *chn);
@@ -553,6 +555,11 @@ int blkid_probe_sprintf_version(blkid_pr
 	return rc;
 }
 
+int blkid_probe_set_block_size(blkid_probe pr, unsigned block_size)
+{
+	return blkid_probe_sprintf_value(pr, "BLOCK_SIZE", "%u", block_size);
+}
+
 static int blkid_probe_set_usage(blkid_probe pr, int usage)
 {
 	struct blkid_chain *chn = blkid_probe_get_chain(pr);
Index: util-linux/libblkid/src/superblocks/superblocks.h
===================================================================
--- util-linux.orig/libblkid/src/superblocks/superblocks.h	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/superblocks.h	2019-08-29 15:44:38.000000000 +0200
@@ -108,6 +108,8 @@ extern int blkid_probe_set_id_label(blki
 extern int blkid_probe_set_utf8_id_label(blkid_probe pr, const char *name,
 			     const unsigned char *data, size_t len, int enc);
 
+int blkid_probe_set_block_size(blkid_probe pr, unsigned block_size);
+
 extern int blkid_probe_is_bitlocker(blkid_probe pr);
 
 #endif /* _BLKID_SUPERBLOCKS_H */
Index: util-linux/libblkid/src/superblocks/apfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/apfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/apfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -65,6 +65,8 @@ static int probe_apfs(blkid_probe pr, co
 	if (blkid_probe_set_uuid(pr, sb->uuid) < 0)
 		return BLKID_PROBE_NONE;
 
+	blkid_probe_set_block_size(pr, le32_to_cpu(sb->block_size));
+
 	return BLKID_PROBE_OK;
 }
 
Index: util-linux/libblkid/src/superblocks/btrfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/btrfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/btrfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -74,6 +74,7 @@ static int probe_btrfs(blkid_probe pr, c
 
 	blkid_probe_set_uuid(pr, bfs->fsid);
 	blkid_probe_set_uuid_as(pr, bfs->dev_item.uuid, "UUID_SUB");
+	blkid_probe_set_block_size(pr, le32_to_cpu(bfs->sectorsize));
 
 	return 0;
 }
Index: util-linux/libblkid/src/superblocks/hfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/hfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/hfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -241,6 +241,8 @@ static int probe_hfsplus(blkid_probe pr,
 	if (blocksize < HFSPLUS_SECTOR_SIZE)
 		return 1;
 
+	blkid_probe_set_block_size(pr, blocksize);
+
 	memcpy(extents, hfsplus->cat_file.extents, sizeof(extents));
 	cat_block = be32_to_cpu(extents[0].start_block);
 
Index: util-linux/libblkid/src/superblocks/hpfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/hpfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/hpfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -99,6 +99,7 @@ static int probe_hpfs(blkid_probe pr, co
 				hbb->vol_serno[1], hbb->vol_serno[0]);
 	}
 	blkid_probe_sprintf_version(pr, "%u", version);
+	blkid_probe_set_block_size(pr, 512);
 
 	return 0;
 }
Index: util-linux/libblkid/src/superblocks/iso9660.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/iso9660.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/iso9660.c	2019-08-29 15:44:38.000000000 +0200
@@ -182,6 +182,8 @@ static int probe_iso9660(blkid_probe pr,
 
 	memcpy(label, iso->volume_id, sizeof(label));
 
+	blkid_probe_set_block_size(pr, 2048);
+
 	if (!is_str_empty(iso->system_id, sizeof(iso->system_id)))
 		blkid_probe_set_id_label(pr, "SYSTEM_ID",
 				iso->system_id, sizeof(iso->system_id));
Index: util-linux/libblkid/src/superblocks/jfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/jfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/jfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -52,6 +52,7 @@ static int probe_jfs(blkid_probe pr, con
 	if (*((char *) js->js_label) != '\0')
 		blkid_probe_set_label(pr, js->js_label, sizeof(js->js_label));
 	blkid_probe_set_uuid(pr, js->js_uuid);
+	blkid_probe_set_block_size(pr, le32_to_cpu(js->js_bsize));
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/minix.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/minix.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/minix.c	2019-08-29 15:44:38.000000000 +0200
@@ -80,6 +80,7 @@ static int probe_minix(blkid_probe pr,
 	unsigned long zones, ninodes, imaps, zmaps;
 	off_t firstz;
 	size_t zone_size;
+	unsigned block_size;
 
 	data = blkid_probe_get_buffer(pr, 1024,
 			max(sizeof(struct minix_super_block),
@@ -103,6 +104,7 @@ static int probe_minix(blkid_probe pr,
 		zmaps   = minix_swab16(swabme, sb->s_zmap_blocks);
 		firstz  = minix_swab16(swabme, sb->s_firstdatazone);
 		zone_size = sb->s_log_zone_size;
+		block_size = 1024;
 		break;
 	}
 	case 3: {
@@ -114,6 +116,8 @@ static int probe_minix(blkid_probe pr,
 		zmaps   = minix_swab16(swabme, sb->s_zmap_blocks);
 		firstz  = minix_swab16(swabme, sb->s_firstdatazone);
 		zone_size = sb->s_log_zone_size;
+		block_size = minix_swab16(swabme, sb->s_blocksize);
+
 		break;
 	}
 	default:
@@ -143,6 +147,7 @@ static int probe_minix(blkid_probe pr,
 		return 1;
 
 	blkid_probe_sprintf_version(pr, "%d", version);
+	blkid_probe_set_block_size(pr, block_size);
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/nilfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/nilfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/nilfs.c	2019-08-29 15:45:18.000000000 +0200
@@ -157,6 +157,9 @@ static int probe_nilfs2(blkid_probe pr,
 				(unsigned char *) &sb->s_magic))
 		return 1;
 
+	if (le32_to_cpu(sb->s_log_block_size) < 32)
+		blkid_probe_set_block_size(pr, 1024U << le32_to_cpu(sb->s_log_block_size));
+
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/ocfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/ocfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/ocfs.c	2019-08-29 15:45:45.000000000 +0200
@@ -153,6 +153,9 @@ static int probe_ocfs2(blkid_probe pr, c
 		le16_to_cpu(osb->s_major_rev_level),
 		le16_to_cpu(osb->s_minor_rev_level));
 
+	if (le32_to_cpu(osb->s_blocksize_bits) < 32)
+		blkid_probe_set_block_size(pr, 1U << le32_to_cpu(osb->s_blocksize_bits));
+
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/reiserfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/reiserfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/reiserfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -32,7 +32,8 @@ struct reiserfs_super_block {
 
 struct reiser4_super_block {
 	unsigned char	rs4_magic[16];
-	uint16_t	rs4_dummy[2];
+	uint8_t		rs4_dummy[3];
+	uint8_t		rs4_blocksize;
 	unsigned char	rs4_uuid[16];
 	unsigned char	rs4_label[16];
 	uint64_t	rs4_dummy2;
@@ -73,22 +74,29 @@ static int probe_reiser(blkid_probe pr,
 	else
 		blkid_probe_set_version(pr, "3.5");
 
+	blkid_probe_set_block_size(pr, blocksize);
+
 	return 0;
 }
 
 static int probe_reiser4(blkid_probe pr, const struct blkid_idmag *mag)
 {
 	struct reiser4_super_block *rs4;
+	unsigned int blocksize;
 
 	rs4 = blkid_probe_get_sb(pr, mag, struct reiser4_super_block);
 	if (!rs4)
 		return errno ? -errno : 1;
 
+	blocksize = rs4->rs4_blocksize * 256;
+
 	if (*rs4->rs4_label)
 		blkid_probe_set_label(pr, rs4->rs4_label, sizeof(rs4->rs4_label));
 	blkid_probe_set_uuid(pr, rs4->rs4_uuid);
 	blkid_probe_set_version(pr, "4");
 
+	blkid_probe_set_block_size(pr, blocksize);
+
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/xfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/xfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/xfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -173,6 +173,7 @@ static int probe_xfs(blkid_probe pr, con
 		blkid_probe_set_label(pr, (unsigned char *) xs->sb_fname,
 				sizeof(xs->sb_fname));
 	blkid_probe_set_uuid(pr, xs->sb_uuid);
+	blkid_probe_set_block_size(pr, xs->sb_sectsize * 256);
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/vfat.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/vfat.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/vfat.c	2019-08-29 15:44:38.000000000 +0200
@@ -220,6 +220,8 @@ static int fat_valid_superblock(blkid_pr
 	    sector_size < 512 || sector_size > 4096)
 		return 0;
 
+	blkid_probe_set_block_size(pr, sector_size);
+
 	dir_entries = unaligned_le16(&ms->ms_dir_entries);
 	reserved =  le16_to_cpu(ms->ms_reserved);
 	sect_count = unaligned_le16(&ms->ms_sectors);
Index: util-linux/libblkid/src/superblocks/gfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/gfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/gfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -98,6 +98,7 @@ static int probe_gfs2(blkid_probe pr, co
 				sizeof(sbd->sb_locktable));
 		blkid_probe_set_uuid(pr, sbd->sb_uuid);
 		blkid_probe_set_version(pr, "1");
+		blkid_probe_set_block_size(pr, be32_to_cpu(sbd->sb_bsize));
 		return 0;
 	}
 	return 1;
Index: util-linux/libblkid/src/superblocks/befs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/befs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/befs.c	2019-08-29 15:44:38.000000000 +0200
@@ -519,6 +519,9 @@ static int probe_befs(blkid_probe pr, co
 		blkid_probe_sprintf_uuid(pr, (unsigned char *) &volume_id,
 					sizeof(volume_id), "%016" PRIx64,
 					FS64_TO_CPU(volume_id, fs_le));
+
+	blkid_probe_set_block_size(pr, block_size);
+
 	return BLKID_PROBE_OK;
 }
 
Index: util-linux/libblkid/src/superblocks/exfat.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/exfat.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/exfat.c	2019-08-29 15:44:38.000000000 +0200
@@ -137,6 +137,8 @@ static int probe_exfat(blkid_probe pr, c
 	blkid_probe_sprintf_version(pr, "%u.%u",
 			sb->version.vermaj, sb->version.vermin);
 
+	blkid_probe_set_block_size(pr, BLOCK_SIZE(sb));
+
 	return BLKID_PROBE_OK;
 }
 
Index: util-linux/libblkid/src/superblocks/exfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/exfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/exfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -170,7 +170,11 @@ static int probe_exfs(blkid_probe pr, co
 	if (*xs->sb_fname != '\0')
 		blkid_probe_set_label(pr, (unsigned char *) xs->sb_fname,
 				sizeof(xs->sb_fname));
+
 	blkid_probe_set_uuid(pr, xs->sb_uuid);
+
+	blkid_probe_set_block_size(pr, be32_to_cpu(xs->sb_blocksize));
+
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/f2fs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/f2fs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/f2fs.c	2019-08-29 15:46:17.000000000 +0200
@@ -78,6 +78,8 @@ static int probe_f2fs(blkid_probe pr, co
 
 	blkid_probe_set_uuid(pr, sb->uuid);
 	blkid_probe_sprintf_version(pr, "%u.%u", vermaj, vermin);
+	if (le32_to_cpu(sb->log_blocksize) < 32)
+		blkid_probe_set_block_size(pr, 1U << le32_to_cpu(sb->log_blocksize));
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/ntfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/ntfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/ntfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -204,6 +204,8 @@ static int probe_ntfs(blkid_probe pr, co
 		attr_off += attr_len;
 	}
 
+	blkid_probe_set_block_size(pr, sector_size);
+
 	blkid_probe_sprintf_uuid(pr,
 			(unsigned char *) &ns->volume_serial,
 			sizeof(ns->volume_serial),
Index: util-linux/libblkid/src/superblocks/romfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/romfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/romfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -34,6 +34,9 @@ static int probe_romfs(blkid_probe pr, c
 	if (*((char *) ros->ros_volume) != '\0')
 		blkid_probe_set_label(pr, ros->ros_volume,
 				sizeof(ros->ros_volume));
+
+	blkid_probe_set_block_size(pr, 1024);
+
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/squashfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/squashfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/squashfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -71,6 +71,8 @@ static int probe_squashfs3(blkid_probe p
 
 	blkid_probe_sprintf_version(pr, "%u.%u", vermaj, vermin);
 
+	blkid_probe_set_block_size(pr, 1024);
+
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/udf.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/udf.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/udf.c	2019-08-29 15:44:38.000000000 +0200
@@ -464,6 +464,8 @@ real_blksz:
 		 * E.g. number 0x0150 is revision 1.50, number 0x0201 is revision 2.01. */
 		blkid_probe_sprintf_version(pr, "%x.%02x", (unsigned int)(udf_rev >> 8), (unsigned int)(udf_rev & 0xFF));
 
+	blkid_probe_set_block_size(pr, bs);
+
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/ufs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/ufs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/ufs.c	2019-08-29 15:44:38.000000000 +0200
@@ -233,6 +233,11 @@ found:
 			(unsigned char *) &ufs->fs_magic))
 		return 1;
 
+	if (!is_be)
+		blkid_probe_set_block_size(pr, le32_to_cpu(ufs->fs_fsize));
+	else
+		blkid_probe_set_block_size(pr, be32_to_cpu(ufs->fs_fsize));
+
 	return 0;
 }
 
Index: util-linux/libblkid/src/superblocks/vxfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/vxfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/vxfs.c	2019-08-29 15:44:38.000000000 +0200
@@ -12,6 +12,15 @@
 struct vxfs_super_block {
 	uint32_t		vs_magic;
 	int32_t			vs_version;
+	uint32_t		vs_ctime;
+	uint32_t		vs_cutime;
+	uint32_t		__unused1;
+	uint32_t		__unused2;
+	uint32_t		vs_old_logstart;
+	uint32_t		vs_old_logend;
+	uint32_t		vs_bsize;
+	uint32_t		vs_size;
+	uint32_t		vs_dsize;
 };
 
 static int probe_vxfs(blkid_probe pr, const struct blkid_idmag *mag)
@@ -22,7 +31,13 @@ static int probe_vxfs(blkid_probe pr, co
 	if (!vxs)
 		return errno ? -errno : 1;
 
-	blkid_probe_sprintf_version(pr, "%u", (unsigned int) vxs->vs_version);
+	if (le32_to_cpu(vxs->vs_magic) == 0xa501fcf5) {
+		blkid_probe_sprintf_version(pr, "%u", (unsigned int)le32_to_cpu(vxs->vs_version));
+		blkid_probe_set_block_size(pr, le32_to_cpu(vxs->vs_bsize));
+	} else if (be32_to_cpu(vxs->vs_magic) == 0xa501fcf5) {
+		blkid_probe_sprintf_version(pr, "%u", (unsigned int)be32_to_cpu(vxs->vs_version));
+		blkid_probe_set_block_size(pr, be32_to_cpu(vxs->vs_bsize));
+	}
 	return 0;
 }
 
@@ -35,6 +50,7 @@ const struct blkid_idinfo vxfs_idinfo =
 	.magics		=
 	{
 		{ .magic = "\365\374\001\245", .len = 4, .kboff = 1 },
+		{ .magic = "\245\001\374\365", .len = 4, .kboff = 8 },
 		{ NULL }
 	}
 };
Index: util-linux/libblkid/src/superblocks/zfs.c
===================================================================
--- util-linux.orig/libblkid/src/superblocks/zfs.c	2019-08-29 15:44:38.000000000 +0200
+++ util-linux/libblkid/src/superblocks/zfs.c	2019-08-29 15:46:36.000000000 +0200
@@ -37,6 +37,7 @@ struct zfs_uberblock {
 
 #define DATA_TYPE_UINT64 8
 #define DATA_TYPE_STRING 9
+#define DATA_TYPE_DIRECTORY 19
 
 struct nvpair {
 	uint32_t	nvp_size;
@@ -60,32 +61,37 @@ struct nvuint64 {
 	uint64_t	nvu_value;
 };
 
+struct nvdirectory {
+	uint32_t	nvd_type;
+	uint32_t	nvd_unknown[3];
+};
+
 struct nvlist {
 	uint32_t	nvl_unknown[3];
 	struct nvpair	nvl_nvpair;
 };
 
-static int zfs_process_value(blkid_probe pr, char *name, size_t namelen,
-			     void *value, size_t max_value_size)
+static void zfs_process_value(blkid_probe pr, char *name, size_t namelen,
+			     void *value, size_t max_value_size, unsigned directory_level)
 {
 	if (strncmp(name, "name", namelen) == 0 &&
-	    sizeof(struct nvstring) <= max_value_size) {
+	    sizeof(struct nvstring) <= max_value_size &&
+	    !directory_level) {
 		struct nvstring *nvs = value;
 		uint32_t nvs_type = be32_to_cpu(nvs->nvs_type);
 		uint32_t nvs_strlen = be32_to_cpu(nvs->nvs_strlen);
 
 		if (nvs_type != DATA_TYPE_STRING ||
 		    (uint64_t)nvs_strlen + sizeof(*nvs) > max_value_size)
-			return 0;
+			return;
 
 		DBG(LOWPROBE, ul_debug("nvstring: type %u string %*s\n",
 				       nvs_type, nvs_strlen, nvs->nvs_string));
 
 		blkid_probe_set_label(pr, nvs->nvs_string, nvs_strlen);
-
-		return 1;
 	} else if (strncmp(name, "guid", namelen) == 0 &&
-		   sizeof(struct nvuint64) <= max_value_size) {
+		   sizeof(struct nvuint64) <= max_value_size &&
+		   !directory_level) {
 		struct nvuint64 *nvu = value;
 		uint32_t nvu_type = be32_to_cpu(nvu->nvu_type);
 		uint64_t nvu_value;
@@ -94,17 +100,16 @@ static int zfs_process_value(blkid_probe
 		nvu_value = be64_to_cpu(nvu_value);
 
 		if (nvu_type != DATA_TYPE_UINT64)
-			return 0;
+			return;
 
 		DBG(LOWPROBE, ul_debug("nvuint64: type %u value %"PRIu64"\n",
 				       nvu_type, nvu_value));
 
 		blkid_probe_sprintf_value(pr, "UUID_SUB",
 					  "%"PRIu64, nvu_value);
-
-		return 1;
 	} else if (strncmp(name, "pool_guid", namelen) == 0 &&
-		   sizeof(struct nvuint64) <= max_value_size) {
+		   sizeof(struct nvuint64) <= max_value_size &&
+		   !directory_level) {
 		struct nvuint64 *nvu = value;
 		uint32_t nvu_type = be32_to_cpu(nvu->nvu_type);
 		uint64_t nvu_value;
@@ -113,7 +118,7 @@ static int zfs_process_value(blkid_probe
 		nvu_value = be64_to_cpu(nvu_value);
 
 		if (nvu_type != DATA_TYPE_UINT64)
-			return 0;
+			return;
 
 		DBG(LOWPROBE, ul_debug("nvuint64: type %u value %"PRIu64"\n",
 				       nvu_type, nvu_value));
@@ -121,10 +126,21 @@ static int zfs_process_value(blkid_probe
 		blkid_probe_sprintf_uuid(pr, (unsigned char *) &nvu_value,
 					 sizeof(nvu_value),
 					 "%"PRIu64, nvu_value);
-		return 1;
-	}
+	} else if (strncmp(name, "ashift", namelen) == 0 &&
+		   sizeof(struct nvuint64) <= max_value_size) {
+		struct nvuint64 *nvu = value;
+		uint32_t nvu_type = be32_to_cpu(nvu->nvu_type);
+		uint64_t nvu_value;
 
-	return 0;
+		memcpy(&nvu_value, &nvu->nvu_value, sizeof(nvu_value));
+		nvu_value = be64_to_cpu(nvu_value);
+
+		if (nvu_type != DATA_TYPE_UINT64)
+			return;
+
+		if (nvu_value < 32)
+			blkid_probe_set_block_size(pr, 1U << nvu_value);
+	}
 }
 
 static void zfs_extract_guid_name(blkid_probe pr, loff_t offset)
@@ -133,7 +149,7 @@ static void zfs_extract_guid_name(blkid_
 	struct nvlist *nvl;
 	struct nvpair *nvp;
 	size_t left = 4096;
-	int found = 0;
+	unsigned directory_level = 0;
 
 	offset = (offset & ~(VDEV_LABEL_SIZE - 1)) + VDEV_LABEL_NVPAIR;
 
@@ -152,16 +168,26 @@ static void zfs_extract_guid_name(blkid_
 	nvp = &nvl->nvl_nvpair;
 	left -= (unsigned char *)nvp - p; /* Already used up 12 bytes */
 
-	while (left > sizeof(*nvp) && nvp->nvp_size != 0 && found < 3) {
+	while (left > sizeof(*nvp)) {
 		uint32_t nvp_size = be32_to_cpu(nvp->nvp_size);
 		uint32_t nvp_namelen = be32_to_cpu(nvp->nvp_namelen);
 		uint64_t namesize = ((uint64_t)nvp_namelen + 3) & ~3;
 		size_t max_value_size;
 		void *value;
 
+		if (!nvp->nvp_size) {
+			if (!directory_level)
+				break;
+			directory_level--;
+			nvp_size = 8;
+			goto cont;
+		}
+
 		DBG(LOWPROBE, ul_debug("left %zd nvp_size %u\n",
 				       left, nvp_size));
 
+		fprintf(stderr, "processing: '%.*s'\n", nvp_namelen, nvp->nvp_name);
+
 		/* nvpair fits in buffer and name fits in nvpair? */
 		if (nvp_size > left || namesize + sizeof(*nvp) > nvp_size)
 			break;
@@ -174,9 +200,21 @@ static void zfs_extract_guid_name(blkid_
 		max_value_size = nvp_size - (namesize + sizeof(*nvp));
 		value = nvp->nvp_name + namesize;
 
-		found += zfs_process_value(pr, nvp->nvp_name, nvp_namelen,
-					   value, max_value_size);
+		if (sizeof(struct nvdirectory) <= max_value_size) {
+			struct nvdirectory *nvu = value;
+			if (be32_to_cpu(nvu->nvd_type) == DATA_TYPE_DIRECTORY) {
+				nvp_size = sizeof(*nvp) + namesize + sizeof(*nvu);
+				directory_level++;
+				goto cont;
+			}
+		}
 
+		zfs_process_value(pr, nvp->nvp_name, nvp_namelen,
+				  value, max_value_size, directory_level);
+
+cont:
+		if (nvp_size > left)
+			break;
 		left -= nvp_size;
 
 		nvp = (struct nvpair *)((char *)nvp + nvp_size);


