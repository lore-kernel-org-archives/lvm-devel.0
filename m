From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Sep 2010 19:09:40 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20100927190940.21831.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-09-27 19:09:36

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	                 make.tmpl.in 
	lib/config     : config.c config.h 
	lib/format_text: format-text.c 
	lib/label      : label.c 
	lib/misc       : crc.c crc.h 
Added files:
	lib/misc       : crc_gen.c 

Log message:
	Speed up CRC32 calculations by using a larger lookup table.
	
	Use -DDEBUG_CRC32 to revert to old function and check new one gives same result.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.255&r2=1.256
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1736&r2=1.1737
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.415&r2=1.416
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/crc_gen.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/crc.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/crc.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/VERSION	2010/09/24 16:24:57	1.255
+++ LVM2/VERSION	2010/09/27 19:09:34	1.256
@@ -1 +1 @@
-2.02.74(2)-cvs (2010-09-24)
+2.02.75(2)-cvs (2010-09-24)
--- LVM2/VERSION_DM	2010/09/24 16:24:57	1.64
+++ LVM2/VERSION_DM	2010/09/27 19:09:34	1.65
@@ -1 +1 @@
-1.02.55-cvs (2010-09-24)
+1.02.56-cvs (2010-09-24)
--- LVM2/WHATS_NEW	2010/09/24 16:24:57	1.1736
+++ LVM2/WHATS_NEW	2010/09/27 19:09:34	1.1737
@@ -1,3 +1,7 @@
+Version 2.02.75 - 
+=====================================
+  Speed up CRC32 calculations by using a larger lookup table.
+
 Version 2.02.74 - 24th September 2010
 =====================================
   Allow : and @ to be escaped with \ in device names of PVs.
@@ -17,7 +21,7 @@
   Add configure --with-default-data-alignment.
   Update heuristic used for default and detected data alignment.
   Add "devices/default_data_alignment" to lvm.conf.
-  Add implmentation for simple numeric 'get' property functions.
+  Add implementation for simple numeric 'get' property functions.
   Define GET_NUM_PROPERTY_FN macro to simplify numeric property 'get' function
   Add properties.[ch] to lib/report using columns.h.
   Add macro definitions to report infrastructure for character array length.
--- LVM2/WHATS_NEW_DM	2010/09/24 16:24:57	1.415
+++ LVM2/WHATS_NEW_DM	2010/09/27 19:09:34	1.416
@@ -1,3 +1,6 @@
+Version 1.02.56 - 
+=====================================
+
 Version 1.02.55 - 24th September 2010
 =====================================
   Fix the way regions are marked complete to avoid slow --nosync cmirror I/O.
--- LVM2/make.tmpl.in	2010/08/16 17:49:26	1.110
+++ LVM2/make.tmpl.in	2010/09/27 19:09:34	1.111
@@ -113,6 +113,7 @@
 
 #CFLAGS += -W -Wconversion -Wpointer-arith -Wbad-function-cast -Wcast-qual
 #CFLAGS += -pedantic -std=gnu99
+#CFLAGS += -DDEBUG_CRC32
 
 CFLAGS += @COPTIMISE_FLAG@
 
--- LVM2/lib/config/config.c	2010/07/09 15:34:42	1.80
+++ LVM2/lib/config/config.c	2010/09/27 19:09:34	1.81
@@ -239,8 +239,8 @@
 	}
 
 	if (checksum_fn && checksum !=
-	    (checksum_fn(checksum_fn(INITIAL_CRC, p->fb, size),
-			 p->fb + size, size2))) {
+	    (checksum_fn(checksum_fn(INITIAL_CRC, (uint8_t *)p->fb, size),
+			 (uint8_t *)(p->fb + size), size2))) {
 		log_error("%s: Checksum error", dev_name(dev));
 		goto out;
 	}
--- LVM2/lib/config/config.h	2009/10/22 10:38:07	1.30
+++ LVM2/lib/config/config.h	2010/09/27 19:09:34	1.31
@@ -60,7 +60,7 @@
 				     const char *config_settings);
 void destroy_config_tree(struct config_tree *cft);
 
-typedef uint32_t (*checksum_fn_t) (uint32_t initial, const void *buf, uint32_t size);
+typedef uint32_t (*checksum_fn_t) (uint32_t initial, const uint8_t *buf, uint32_t size);
 
 int read_config_fd(struct config_tree *cft, struct device *dev,
 		   off_t offset, size_t size, off_t offset2, size_t size2,
--- LVM2/lib/format_text/format-text.c	2010/08/26 12:22:05	1.144
+++ LVM2/lib/format_text/format-text.c	2010/09/27 19:09:35	1.145
@@ -332,7 +332,7 @@
 	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah))
 		goto_bad;
 
-	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, mdah->magic,
+	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 						  MDA_HEADER_SIZE -
 						  sizeof(mdah->checksum_xl)))) {
 		log_error("Incorrect metadata area header checksum on %s"
@@ -380,7 +380,7 @@
 	mdah->start = start_byte;
 
 	_xlate_mdah(mdah);
-	mdah->checksum_xl = xlate32(calc_crc(INITIAL_CRC, mdah->magic,
+	mdah->checksum_xl = xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 					     MDA_HEADER_SIZE -
 					     sizeof(mdah->checksum_xl)));
 
@@ -650,12 +650,12 @@
 			goto_out;
 	}
 
-	mdac->rlocn.checksum = calc_crc(INITIAL_CRC, fidtc->raw_metadata_buf,
+	mdac->rlocn.checksum = calc_crc(INITIAL_CRC, (uint8_t *)fidtc->raw_metadata_buf,
 					(uint32_t) (mdac->rlocn.size -
 						    new_wrap));
 	if (new_wrap)
 		mdac->rlocn.checksum = calc_crc(mdac->rlocn.checksum,
-						fidtc->raw_metadata_buf +
+						(uint8_t *)fidtc->raw_metadata_buf +
 						mdac->rlocn.size -
 						new_wrap, (uint32_t) new_wrap);
 
--- LVM2/lib/label/label.c	2010/07/09 15:34:44	1.50
+++ LVM2/lib/label/label.c	2010/09/27 19:09:35	1.51
@@ -142,8 +142,8 @@
 					 sector + scan_sector);
 				continue;
 			}
-			if (calc_crc(INITIAL_CRC, &lh->offset_xl, LABEL_SIZE -
-				     ((uintptr_t) &lh->offset_xl - (uintptr_t) lh)) !=
+			if (calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl, LABEL_SIZE -
+				     ((uint8_t *) &lh->offset_xl - (uint8_t *) lh)) !=
 			    xlate32(lh->crc_xl)) {
 				log_info("Label checksum incorrect on %s - "
 					 "ignoring", dev_name(dev));
@@ -323,8 +323,8 @@
 	if (!(label->labeller->ops->write)(label, buf))
 		return_0;
 
-	lh->crc_xl = xlate32(calc_crc(INITIAL_CRC, &lh->offset_xl, LABEL_SIZE -
-				      ((uintptr_t) &lh->offset_xl - (uintptr_t) lh)));
+	lh->crc_xl = xlate32(calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl, LABEL_SIZE -
+				      ((uint8_t *) &lh->offset_xl - (uint8_t *) lh)));
 
 	if (!dev_open(dev))
 		return_0;
/cvs/lvm2/LVM2/lib/misc/crc_gen.c,v  -->  standard output
revision 1.1
--- LVM2/lib/misc/crc_gen.c
+++ -	2010-09-27 19:09:39.765327000 +0000
@@ -0,0 +1,47 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * Helper program to generate table included in crc.c.
+ */
+#include "lib.h"
+
+int main(int argc, char **argv)
+{
+	uint32_t crc, i, j;
+
+	printf("\t/* CRC-32 byte lookup table generated by crcgen.c */\n");
+	printf("\tstatic const uint32_t crctab[] = {");
+
+	for (i = 0; i < 256; i++) {
+		crc = i;
+		for (j = 0; j < 8; j++) {
+			if (crc & 1)
+				crc = 0xedb88320L ^ (crc >> 1);
+			else
+				crc = crc >> 1;
+		}
+
+		if (i % 8)
+			printf(" ");
+		else
+			printf("\n\t\t");
+
+		printf("0x%08.8x,", crc);
+	}
+
+	printf("\n\t};\n");
+
+	return 0;
+}
--- LVM2/lib/misc/crc.c	2008/01/30 14:00:00	1.6
+++ LVM2/lib/misc/crc.c	2010/09/27 19:09:35	1.7
@@ -18,7 +18,73 @@
 #include "crc.h"
 
 /* Calculate an endian-independent CRC of supplied buffer */
-uint32_t calc_crc(uint32_t initial, const void *buf, uint32_t size)
+#ifndef DEBUG_CRC32
+uint32_t calc_crc(uint32_t initial, const uint8_t *buf, uint32_t size)
+#else
+static uint32_t _calc_crc_new(uint32_t initial, const uint8_t *buf, uint32_t size)
+#endif
+{
+	/* CRC-32 byte lookup table generated by crcgen.c */
+	static const uint32_t crctab[] = {
+		0x00000000, 0x77073096, 0xee0e612c, 0x990951ba, 0x076dc419, 0x706af48f, 0xe963a535, 0x9e6495a3,
+		0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988, 0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91,
+		0x1db71064, 0x6ab020f2, 0xf3b97148, 0x84be41de, 0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
+		0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec, 0x14015c4f, 0x63066cd9, 0xfa0f3d63, 0x8d080df5,
+		0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172, 0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,
+		0x35b5a8fa, 0x42b2986c, 0xdbbbc9d6, 0xacbcf940, 0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
+		0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116, 0x21b4f4b5, 0x56b3c423, 0xcfba9599, 0xb8bda50f,
+		0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924, 0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,
+		0x76dc4190, 0x01db7106, 0x98d220bc, 0xefd5102a, 0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
+		0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818, 0x7f6a0dbb, 0x086d3d2d, 0x91646c97, 0xe6635c01,
+		0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e, 0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457,
+		0x65b0d9c6, 0x12b7e950, 0x8bbeb8ea, 0xfcb9887c, 0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
+		0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2, 0x4adfa541, 0x3dd895d7, 0xa4d1c46d, 0xd3d6f4fb,
+		0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0, 0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9,
+		0x5005713c, 0x270241aa, 0xbe0b1010, 0xc90c2086, 0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
+		0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4, 0x59b33d17, 0x2eb40d81, 0xb7bd5c3b, 0xc0ba6cad,
+		0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a, 0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683,
+		0xe3630b12, 0x94643b84, 0x0d6d6a3e, 0x7a6a5aa8, 0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
+		0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe, 0xf762575d, 0x806567cb, 0x196c3671, 0x6e6b06e7,
+		0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc, 0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5,
+		0xd6d6a3e8, 0xa1d1937e, 0x38d8c2c4, 0x4fdff252, 0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
+		0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60, 0xdf60efc3, 0xa867df55, 0x316e8eef, 0x4669be79,
+		0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236, 0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f,
+		0xc5ba3bbe, 0xb2bd0b28, 0x2bb45a92, 0x5cb36a04, 0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
+		0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a, 0x9c0906a9, 0xeb0e363f, 0x72076785, 0x05005713,
+		0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38, 0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21,
+		0x86d3d2d4, 0xf1d4e242, 0x68ddb3f8, 0x1fda836e, 0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
+		0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c, 0x8f659eff, 0xf862ae69, 0x616bffd3, 0x166ccf45,
+		0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2, 0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db,
+		0xaed16a4a, 0xd9d65adc, 0x40df0b66, 0x37d83bf0, 0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
+		0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf,
+		0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94, 0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d,
+	};
+	uint32_t *start = (uint32_t *) buf;
+	uint32_t *end = (uint32_t *) (buf + (size & 0xfffffffc));
+	uint32_t crc = initial;
+   
+	/* Process 4 bytes per iteration */
+	while (start < end) {
+		crc = crc ^ *start++;
+		crc = crctab[crc & 0xff] ^ crc >> 8;
+		crc = crctab[crc & 0xff] ^ crc >> 8;
+		crc = crctab[crc & 0xff] ^ crc >> 8;
+		crc = crctab[crc & 0xff] ^ crc >> 8;
+	}
+
+	/* Process any bytes left over */
+	buf = (uint8_t *) start;
+	size = size & 0x3;
+	while (size--) {
+		crc = crc ^ *buf++;
+		crc = crctab[crc & 0xff] ^ crc >> 8;
+	}
+
+	return crc;
+}
+
+#ifdef DEBUG_CRC32
+static uint32_t _calc_crc_old(uint32_t initial, const uint8_t *buf, uint32_t size)
 {
 	static const uint32_t crctab[] = {
 		0x00000000, 0x1db71064, 0x3b6e20c8, 0x26d930ac,
@@ -27,12 +93,24 @@
 		0x9b64c2b0, 0x86d3d2d4, 0xa00ae278, 0xbdbdf21c
 	};
 	uint32_t i, crc = initial;
-	const uint8_t *data = (const uint8_t *) buf;
 
 	for (i = 0; i < size; i++) {
-		crc ^= *data++;
+		crc ^= *buf++;
 		crc = (crc >> 4) ^ crctab[crc & 0xf];
 		crc = (crc >> 4) ^ crctab[crc & 0xf];
 	}
 	return crc;
 }
+
+uint32_t calc_crc(uint32_t initial, const uint8_t *buf, uint32_t size)
+{
+	uint32_t new_crc = _calc_crc_new(initial, buf, size);
+	uint32_t old_crc = _calc_crc_old(initial, buf, size);
+
+	if (new_crc != old_crc)
+		log_error(INTERNAL_ERROR "Old and new crc32 algorithms mismatch: 0x%08x != 0x%08x", old_crc, new_crc);
+
+	return old_crc;
+}
+
+#endif /* DEBUG_CRC32 */
--- LVM2/lib/misc/crc.h	2007/08/20 20:55:27	1.5
+++ LVM2/lib/misc/crc.h	2010/09/27 19:09:36	1.6
@@ -18,6 +18,6 @@
 
 #define INITIAL_CRC 0xf597a6cf
 
-uint32_t calc_crc(uint32_t initial, const void *buf, uint32_t size);
+uint32_t calc_crc(uint32_t initial, const uint8_t *buf, uint32_t size);
 
 #endif


