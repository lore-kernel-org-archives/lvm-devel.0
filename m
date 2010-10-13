From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Oct 2010 12:18:54 -0000
Subject: LVM2 lib/metadata/metadata.c ./configure.in li ...
Message-ID: <20101013121854.31499.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-13 12:18:54

Modified files:
	lib/metadata   : metadata.c 
	.              : configure.in 
	lib/misc       : configure.h.in 

Log message:
	Don't use floor() in _bitset_with_random_bits
	
	Use _even_rand() function instead of floor() in _bitset_with_random_bits().
	floor() function is missing in dietlibc (on architectures other than x86).
	Moreover using floor() to clip rand results does not assure even result
	distribution. _even_rand() uses integer arithmetic only and is designed to
	return evenly distributed results.
	
	> Looks OK to me. It took a while to decipher what is the exact meaning of
	> the loop in _even_rand (to a non-pseudorandomness-expert) but I am
	> fairly comfortable with it now. If I understand this correctly, it
	> rejects numbers that come from an "incomplete" slice of the RAND_MAX
	> space (considering the number space [0, RAND_MAX] is divided into some
	> "max"-sized slices and at most a single smaller slice, between [n*max,
	> RAND_MAX] for suitable n -- numbers from this last slice are discarded
	> because they could distort the distribution in favour of smaller
	> numbers).
	
	Signed-off-by: Przemyslaw Iskra <sparky <at> pld-linux.org>
	Reviewed-by: Petr Rockai <prockai <at> redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.404&r2=1.405
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.155&r2=1.156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/lib/metadata/metadata.c	2010/10/05 17:34:06	1.404
+++ LVM2/lib/metadata/metadata.c	2010/10/13 12:18:53	1.405
@@ -1015,6 +1015,29 @@
 	return (uint64_t) size / extent_size;
 }
 
+/*
+ * Return random integer in [0,max) interval
+ *
+ * The loop rejects numbers that come from an "incomplete" slice of the
+ * RAND_MAX space (considering the number space [0, RAND_MAX] is divided
+ * into some "max"-sized slices and at most a single smaller slice,
+ * between [n*max, RAND_MAX] for suitable n -- numbers from this last slice
+ * are discarded because they could distort the distribution in favour of
+ * smaller numbers.
+ */
+static unsigned _even_rand( unsigned *seed, unsigned max )
+{
+	unsigned r, ret;
+
+	/* make sure distribution is even */
+	do {
+		r = (unsigned) rand_r( seed );
+		ret = r % max;
+	} while ( r - ret > RAND_MAX - max );
+
+	return ret;
+}
+
 static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bits,
 					    uint32_t num_set_bits, unsigned *seed)
 {
@@ -1037,7 +1060,7 @@
 	/* Perform loop num_set_bits times, selecting one bit each time */
 	while (i++ < num_bits) {
 		/* Select a random bit between 0 and (i-1) inclusive. */
-		bit_selected = (unsigned) floor(i * (rand_r(seed) / (RAND_MAX + 1.0)));
+		bit_selected = _even_rand(seed, i);
 
 		/*
 		 * If the bit was already set, set the new bit that became
--- LVM2/configure.in	2010/08/23 11:37:02	1.155
+++ LVM2/configure.in	2010/10/13 12:18:53	1.156
@@ -125,8 +125,7 @@
 
 ################################################################################
 dnl -- Check for functions
-AC_SEARCH_LIBS([floor], [m], , [AC_MSG_ERROR(bailing out)])
-AC_CHECK_FUNCS([floor ftruncate gethostname getpagesize \
+AC_CHECK_FUNCS([ftruncate gethostname getpagesize \
   gettimeofday memset mkdir mkfifo rmdir munmap nl_langinfo setenv setlocale \
   strcasecmp strchr strcspn strspn strdup strncasecmp strerror strrchr \
   strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])
--- LVM2/lib/misc/configure.h.in	2010/08/21 00:16:37	1.28
+++ LVM2/lib/misc/configure.h.in	2010/10/13 12:18:53	1.29
@@ -111,9 +111,6 @@
 /* Define to 1 if you have the <fcntl.h> header file. */
 #undef HAVE_FCNTL_H
 
-/* Define to 1 if you have the `floor' function. */
-#undef HAVE_FLOOR
-
 /* Define to 1 if you have the `fork' function. */
 #undef HAVE_FORK
 


