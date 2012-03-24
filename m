From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Mar 2012 02:58:57 -0000
Subject: LVM2/veritysetup veritysetup.c
Message-ID: <20120324025857.17866.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-24 02:58:57

Modified files:
	veritysetup    : veritysetup.c 

Log message:
	fixes/improvements

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/veritysetup/veritysetup.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/veritysetup/veritysetup.c	2012/03/24 02:00:00	1.1
+++ LVM2/veritysetup/veritysetup.c	2012/03/24 02:58:56	1.2
@@ -78,11 +78,11 @@
 static int version = -1;
 static int data_block_size = 0;
 static int hash_block_size = 0;
-static long long hash_start = 0;
+static char *data_blocks_string = NULL;
 static long long data_blocks = 0;
+static char *hash_start_string = NULL;
+static long long hash_start = 0;
 static const char *salt_string = NULL;
-static const char *hash_start_string = NULL;
-static const char *data_blocks_string = NULL;
 
 static FILE *data_file;
 static FILE *hash_file;
@@ -127,7 +127,9 @@
 #define DM_VERITY_SIGNATURE	"verity\0\0"
 #define DM_VERITY_VERSION	0
 
-__attribute__ ((noreturn))
+#if defined(__GNUC__) && __GNUC__ >= 2
+	__attribute__((__noreturn__))
+#endif
 static void help(poptContext popt_context,
 		 enum poptCallbackReason reason,
 		 struct poptOption *key,
@@ -170,9 +172,8 @@
 };
 
 #if defined(__GNUC__) && __GNUC__ >= 2
-	__attribute__((__format__(__printf__, 1, 2)))
+	__attribute__((__format__(__printf__, 1, 2), __noreturn__))
 #endif
-__attribute__((noreturn))
 static void exit_err(const char *msg, ...)
 {
 	va_list args;
@@ -183,7 +184,9 @@
 	exit(2);
 }
 
-__attribute__((noreturn))
+#if defined(__GNUC__) && __GNUC__ >= 2
+	__attribute__((__noreturn__))
+#endif
 static void stream_err(FILE *f, const char *msg)
 {
 	if (ferror(f)) {
@@ -622,6 +625,8 @@
 static void create_or_verify(void)
 {
 	int i;
+
+	memset(calculated_digest, 0, digest_size);
 	if (mode != MODE_ACTIVATE)
 		for (i = 0; i < levels; i++) {
 			block_fseek(hash_file, hash_level_block[i], hash_block_size);
@@ -682,7 +687,9 @@
 	}
 }
 
-__attribute__((noreturn))
+#if defined(__GNUC__) && __GNUC__ >= 2
+	__attribute__((__noreturn__))
+#endif
 static void activate(void)
 {
 	int i;
@@ -769,8 +776,9 @@
 			exit_err("hash block size (%d) does not match superblock value (%d)", hash_block_size, 1 << superblock.hash_block_bits);
 	}
 
-	if (!data_blocks) {
+	if (!data_blocks_string) {
 		data_blocks = sb_data_blocks;
+		data_blocks_string = (char *)"";
 	} else {
 		if (data_blocks != sb_data_blocks)
 			exit_err("data blocks (%lld) does not match superblock value (%lld)", data_blocks, sb_data_blocks);
@@ -803,8 +811,8 @@
 	superblock.data_block_bits = ffs(data_block_size) - 1;
 	superblock.hash_block_bits = ffs(hash_block_size) - 1;
 	superblock.salt_size = htons(salt_size);
-	superblock.data_blocks_hi = htonl(data_blocks >> 31 >> 1);
-	superblock.data_blocks_lo = htonl(data_blocks & 0xFFFFFFFF);
+	superblock.data_blocks_hi = htonl(data_file_blocks >> 31 >> 1);
+	superblock.data_blocks_lo = htonl(data_file_blocks & 0xFFFFFFFF);
 	strncpy((char *)superblock.algorithm, hash_algorithm, sizeof superblock.algorithm);
 	memcpy(superblock.salt, salt_bytes, salt_size);
 
@@ -818,7 +826,7 @@
 	poptContext popt_context;
 	int r;
 	const char *s;
-	char c;
+	char *end;
 
 	if (sizeof(struct superblock) != 512)
 		exit_err("INTERNAL ERROR: bad superblock size %ld", (long)sizeof(struct superblock));
@@ -879,9 +887,17 @@
 		exit(2);
 	}
 
-	if (hash_start_string)
-		if (sscanf(hash_start_string, "%lld%c", &hash_start, &c) != 1)
+	if (data_blocks_string) {
+		data_blocks = strtoll(data_blocks_string, &end, 10);
+		if (!*data_blocks_string || *end)
+			exit_err("invalid number of data blocks");
+	}
+
+	if (hash_start_string) {
+		hash_start = strtoll(hash_start_string, &end, 10);
+		if (!*hash_start_string || *end)
 			exit_err("invalid hash start");
+	}
 
 	if (hash_start < 0 ||
 	   (unsigned long long)hash_start * 512 / 512 != hash_start ||
@@ -919,10 +935,6 @@
 	if (hash_block_size < 512 || (hash_block_size & (hash_block_size - 1)) || hash_block_size >= 1U << 31)
 		exit_err("invalid hash block size");
 
-	if (data_blocks_string)
-		if (sscanf(data_blocks_string, "%lld%c", &data_blocks, &c) != 1)
-			exit_err("invalid number of data blocks");
-
 	if (data_blocks < 0 || (off_t)data_blocks < 0 || (off_t)data_blocks != data_blocks)
 		exit_err("invalid number of data blocks");
 
@@ -931,9 +943,8 @@
 
 	if (data_file_blocks < data_blocks)
 		exit_err("data file is too small");
-	if (data_blocks) {
+	if (data_blocks_string)
 		data_file_blocks = data_blocks;
-	}
 
 	if (use_superblock) {
 		hash_start = hash_start + (sizeof(struct superblock) + 511) / 512;


