From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:55 +0100
Subject: [PATCH 14/15] Add *testing* LUKS1 keystore implementation.
In-Reply-To: <56eb4722a65edf5a12d79098ab2ec848b3e727b4.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
	<1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
	<589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
	<b43d35ebbdda1be4696b072c222c243cb0645f72.1232488181.git.mbroz@redhat.com>
	<3417d8a2769cc152bd8aef5921716b693360ee15.1232488181.git.mbroz@redhat.com>
	<6d887c3c90806a55ac1cf569425845ce0ed16daa.1232488181.git.mbroz@redhat.com>
	<0cf2e4e850e1c919e0e6bc98504be6d5087caa1c.1232488181.git.mbroz@redhat.com>
	<b8d375b5ca799bd88ff701ba19b93bed02f62343.1232488181.git.mbroz@redhat.com>
	<3d899235af519a0e471dc86df580a991371b91fd.1232488181.git.mbroz@redhat.com>
	<35fcbf3ab1527b121e3a8064a35eab8f7a7a2f1d.1232488181.git.mbroz@redhat.com>
	<11624519b513cc630635406dc8b35f380bb43a9f.1232488181.git.mbroz@redhat.com>
	<8063c7b937ce3760c31028df5e6689d2bb35fde1.1232488181.git.mbroz@redhat.com>
	<56eb4722a65edf5a12d79098ab2ec848b3e727b4.1232488181.git.mbroz@redhat.com>
Message-ID: <900e6948cfd4c8cacb60ea896cb8ffcbe1bf5d7b.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

BIG FAT WARNING: THIS IS JUST BUGGY TEST CODE
PROVIDED ONLY FOR TESTING OF PREVIOUS CODE :-)

This patch tries to implement real keystore handling,
using LUKS1 format.

If you have linear logical volume, formatted using

     cryptsetup luksFormat /dev/VG/LV --align-offset=<extent sectors>

you can import it to lvm as "luks1" keystore using

    lvconvert --crypt luks1 VG/LV

Now is the volume converted to crypto key store
(first extent of former volume) and internal encrypted
volume.

LUKS1 key handler then allows volume activation, using
on disk LUKS metadata.

(See following patch with test script for examples.)

    Notes:
    1) The whole LUKS parsing code was rewrited by me using
    libgcrypt instead of hardcoded SHA1 & PBKDF2 code.

    2) Simple configure script *requires* libgcrypt
    for linking. (In the future, only keystore library
    should require libgcrypt or nss crypto library).

    3) Why I didn't use libluks or libcryptsetup?
    - the luks library code need rewrite, API is not stable,
    some distros removed it from its build
    - there is huge amout of duplicated code which
    LVM already handles better
    - SHA1 is hardcoded in cryptsetup-luks, and it
    can cause serious problem for FIPS certification

    Open question is, if the crypsetup code should be
    fixed and used in lvm through some wrapper
    (which activates keystore device for it) or lvm
    should provide an alternative for key
    management operation.

For now, there is this simple testing alternative.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 configure                |   94 +++++++++-
 configure.in             |   30 +++
 lib/Makefile.in          |    6 +
 lib/crypt/key_handlers.c |    3 +
 lib/crypt/key_luks.c     |  495 ++++++++++++++++++++++++++++++++++++++++++++++
 lib/crypt/lvm-crypto.h   |    3 +
 lib/crypt/pbkdf2.c       |  199 +++++++++++++++++++
 lib/crypt/pbkdf2.h       |   36 ++++
 lib/misc/configure.h.in  |    3 +
 9 files changed, 866 insertions(+), 3 deletions(-)
 create mode 100644 lib/crypt/key_luks.c
 create mode 100644 lib/crypt/pbkdf2.c
 create mode 100644 lib/crypt/pbkdf2.h

diff --git a/configure b/configure
index e4a8f82..2632dbd 100755
--- a/configure
+++ b/configure
@@ -686,6 +686,7 @@ CSCOPE_CMD
 ALLOCA
 LIBOBJS
 POW_LIB
+LIBGCRYPT_CONFIG
 LCOV
 GENHTML
 LVM2CMD_LIB
@@ -700,6 +701,7 @@ CLVMD
 CMDLIB
 COPTIMISE_FLAG
 CRYPTO
+CRYPTO_LUKS1
 DEBUG
 DEVMAPPER
 DMEVENTD
@@ -1328,6 +1330,7 @@ Optional Features:
                           statically.  Default is dynamic linking
   --enable-lvm1_fallback  Use this to fall back and use LVM1 binaries if
                           device-mapper is missing from the kernel
+  --enable-luks1          Enable LUKS1 crypto support
   --disable-readline      Disable readline support
   --disable-realtime      Disable realtime clock support
   --enable-debug          Enable debugging
@@ -8695,6 +8698,88 @@ _ACEOF
 
 fi
 
+{ echo "$as_me:$LINENO: checking whether to enable LUKS1 support" >&5
+echo $ECHO_N "checking whether to enable LUKS1 support... $ECHO_C" >&6; }
+# Check whether --enable-luks1 was given.
+if test "${enable_luks1+set}" = set; then
+  enableval=$enable_luks1; CRYPTO_LUKS1=$enableval
+else
+  CRYPTO_LUKS1=no
+fi
+
+{ echo "$as_me:$LINENO: result: $CRYPTO_LUKS1" >&5
+echo "${ECHO_T}$CRYPTO_LUKS1" >&6; }
+
+if test x$CRYPTO_LUKS1 = xyes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define CRYPT_LUKS1 1
+_ACEOF
+
+
+	if test x$CRYPTO = xnone ; then
+		{ { echo "$as_me:$LINENO: error: Cannot use LUKS without crypto support" >&5
+echo "$as_me: error: Cannot use LUKS without crypto support" >&2;}
+   { (exit 1); exit 1; }; }
+	fi
+
+	# Extract the first word of "libgcrypt-config", so it can be a program name with args.
+set dummy libgcrypt-config; ac_word=$2
+{ echo "$as_me:$LINENO: checking for $ac_word" >&5
+echo $ECHO_N "checking for $ac_word... $ECHO_C" >&6; }
+if test "${ac_cv_path_LIBGCRYPT_CONFIG+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  case $LIBGCRYPT_CONFIG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_LIBGCRYPT_CONFIG="$LIBGCRYPT_CONFIG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_LIBGCRYPT_CONFIG="$as_dir/$ac_word$ac_exec_ext"
+    echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+done
+IFS=$as_save_IFS
+
+  test -z "$ac_cv_path_LIBGCRYPT_CONFIG" && ac_cv_path_LIBGCRYPT_CONFIG="no"
+  ;;
+esac
+fi
+LIBGCRYPT_CONFIG=$ac_cv_path_LIBGCRYPT_CONFIG
+if test -n "$LIBGCRYPT_CONFIG"; then
+  { echo "$as_me:$LINENO: result: $LIBGCRYPT_CONFIG" >&5
+echo "${ECHO_T}$LIBGCRYPT_CONFIG" >&6; }
+else
+  { echo "$as_me:$LINENO: result: no" >&5
+echo "${ECHO_T}no" >&6; }
+fi
+
+
+
+	if test x"$LIBGCRYPT_CONFIG" = x"no" ; then
+		{ { echo "$as_me:$LINENO: error: You selected option which require libgcrypt" >&5
+echo "$as_me: error: You selected option which require libgcrypt" >&2;}
+   { (exit 1); exit 1; }; }
+	fi
+
+	# libgcrypt-config fails here, this must go first
+	if test "x$STATIC_LINK" = xyes; then
+		LIBS="-lgpg-error $LIBS"
+	fi
+
+	LIBGCRYPT_LIBS=`$LIBGCRYPT_CONFIG --libs`
+	LIBS="$LIBGCRYPT_LIBS $LIBS"
+fi
+
 ################################################################################
 { echo "$as_me:$LINENO: checking whether to enable readline" >&5
 echo $ECHO_N "checking whether to enable readline... $ECHO_C" >&6; }
@@ -11753,6 +11838,7 @@ LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile tools/version.h"
 
@@ -12471,6 +12557,7 @@ CSCOPE_CMD!$CSCOPE_CMD$ac_delim
 ALLOCA!$ALLOCA$ac_delim
 LIBOBJS!$LIBOBJS$ac_delim
 POW_LIB!$POW_LIB$ac_delim
+LIBGCRYPT_CONFIG!$LIBGCRYPT_CONFIG$ac_delim
 LCOV!$LCOV$ac_delim
 GENHTML!$GENHTML$ac_delim
 LVM2CMD_LIB!$LVM2CMD_LIB$ac_delim
@@ -12485,6 +12572,7 @@ CLVMD!$CLVMD$ac_delim
 CMDLIB!$CMDLIB$ac_delim
 COPTIMISE_FLAG!$COPTIMISE_FLAG$ac_delim
 CRYPTO!$CRYPTO$ac_delim
+CRYPTO_LUKS1!$CRYPTO_LUKS1$ac_delim
 DEBUG!$DEBUG$ac_delim
 DEVMAPPER!$DEVMAPPER$ac_delim
 DMEVENTD!$DMEVENTD$ac_delim
@@ -12494,8 +12582,6 @@ DM_DEVICE_MODE!$DM_DEVICE_MODE$ac_delim
 DM_DEVICE_UID!$DM_DEVICE_UID$ac_delim
 DM_IOCTLS!$DM_IOCTLS$ac_delim
 DM_LIB_VERSION!$DM_LIB_VERSION$ac_delim
-DM_LIB_PATCHLEVEL!$DM_LIB_PATCHLEVEL$ac_delim
-FSADM!$FSADM$ac_delim
 _ACEOF
 
   if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 97; then
@@ -12537,6 +12623,8 @@ _ACEOF
 ac_delim='%!_!# '
 for ac_last_try in false false false false false :; do
   cat >conf$$subs.sed <<_ACEOF
+DM_LIB_PATCHLEVEL!$DM_LIB_PATCHLEVEL$ac_delim
+FSADM!$FSADM$ac_delim
 GROUP!$GROUP$ac_delim
 HAVE_LIBDL!$HAVE_LIBDL$ac_delim
 HAVE_REALTIME!$HAVE_REALTIME$ac_delim
@@ -12569,7 +12657,7 @@ usrsbindir!$usrsbindir$ac_delim
 LTLIBOBJS!$LTLIBOBJS$ac_delim
 _ACEOF
 
-  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 30; then
+  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 32; then
     break
   elif $ac_last_try; then
     { { echo "$as_me:$LINENO: error: could not make $CONFIG_STATUS" >&5
diff --git a/configure.in b/configure.in
index a5e9236..a1072fb 100644
--- a/configure.in
+++ b/configure.in
@@ -325,6 +325,35 @@ if test x$CRYPTO = xinternal; then
 	AC_DEFINE([CRYPT_INTERNAL], 1, [Define to 1 to include built-in support for crypto.])
 fi
 
+dnl -- LUKS1 keystore support
+AC_MSG_CHECKING(whether to enable LUKS1 support)
+AC_ARG_ENABLE([luks1],
+  [  --enable-luks1          Enable LUKS1 crypto support],
+  [CRYPTO_LUKS1=$enableval], [CRYPTO_LUKS1=no])
+AC_MSG_RESULT($CRYPTO_LUKS1)
+
+if test x$CRYPTO_LUKS1 = xyes; then
+	AC_DEFINE([CRYPT_LUKS1], 1, [Define to 1 to include built-in support for LUKS1 keystore.])
+
+	if test x$CRYPTO = xnone ; then
+		AC_MSG_ERROR(Cannot use LUKS without crypto support)
+	fi
+
+	AC_PATH_PROG(LIBGCRYPT_CONFIG, libgcrypt-config, no)
+
+	if test x"$LIBGCRYPT_CONFIG" = x"no" ; then
+		AC_MSG_ERROR(You selected option which require libgcrypt)
+	fi
+
+	# libgcrypt-config fails here, this must go first
+	if test "x$STATIC_LINK" = xyes; then
+		LIBS="-lgpg-error $LIBS"
+	fi
+
+	LIBGCRYPT_LIBS=`$LIBGCRYPT_CONFIG --libs`
+	LIBS="$LIBGCRYPT_LIBS $LIBS"
+fi
+
 ################################################################################
 dnl -- Disable readline
 AC_MSG_CHECKING(whether to enable readline)
@@ -755,6 +784,7 @@ AC_SUBST(CLVMD)
 AC_SUBST(CMDLIB)
 AC_SUBST(COPTIMISE_FLAG)
 AC_SUBST(CRYPTO)
+AC_SUBST(CRYPTO_LUKS1)
 AC_SUBST(CSCOPE_CMD)
 AC_SUBST(DEBUG)
 AC_SUBST(DEVMAPPER)
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 7167f04..912d1d9 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -131,6 +131,12 @@ ifeq ("@CRYPTO@", "internal")
   SOURCES += crypt/crypt.c
 endif
 
+ifeq ("@CRYPTO_LUKS1@", "yes")
+  SOURCES +=\
+	crypt/key_luks.c \
+	crypt/pbkdf2.c
+endif
+
 ifeq ("@DEVMAPPER@", "yes")
   SOURCES +=\
 	activate/dev_manager.c \
diff --git a/lib/crypt/key_handlers.c b/lib/crypt/key_handlers.c
index 678a260..4380218 100644
--- a/lib/crypt/key_handlers.c
+++ b/lib/crypt/key_handlers.c
@@ -60,6 +60,9 @@ int lvm_keystore_handlers_init()
 
 	// FIXME: here should be library loading
 	dm_list_add(&_keystore_handlers, &_plain_csh.list);
+#ifdef CRYPT_LUKS1
+	dm_list_add(&_keystore_handlers, &keystore_luks1_init()->list);
+#endif
 
 	return 1;
 }
diff --git a/lib/crypt/key_luks.c b/lib/crypt/key_luks.c
new file mode 100644
index 0000000..0f1a3d9
--- /dev/null
+++ b/lib/crypt/key_luks.c
@@ -0,0 +1,495 @@
+/*
+ * Copyright (C) 2008-2009 Red Hat, Inc. All rights reserved.
+ *
+ * LUKS1 & AF merge code, completely rewrited for libgcrypt,
+ * function reference to cryptsetup-luks source,
+ * Copyright (C) 2004-2006, Clemens Fruhwirth
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
+ * LUKS version 1 metadata activation code
+ */
+
+#include <netinet/in.h>
+#include <gcrypt.h>
+#include "lib.h"
+#include "lvm-crypto.h"
+#include "pbkdf2.h"
+
+// This part is copied from LUKS cryptsetup implementation:
+#define LUKS_DIGESTSIZE 20 // since SHA1
+#define SHA1_DIGEST_SIZE LUKS_DIGESTSIZE
+#define LUKS_NUMKEYS 8
+#define SECTOR_SHIFT 9
+
+// Numbers of iterations for the master key digest
+#define LUKS_MKD_ITER 10
+
+#define LUKS_KEY_DISABLED 0x0000DEAD
+#define LUKS_KEY_ENABLED  0x00AC71F3
+
+#define LUKS_STRIPES 4000
+
+#define LUKS_MAGIC "LUKS\xba\xbe"
+
+#define dm_div_up(n, sz) (((n) + (sz) - 1) / (sz))
+#define dm_round_up(n, sz) (dm_div_up((n), (sz)) * (sz))
+
+/*
+ * on disk structure:
+ *
+ * | LUKS header | padding | keyslot 1 | .. | keyslot 8 || <VOLUME DATA>
+ */
+struct luks_keyslot_header {
+		uint32_t active;
+		uint32_t passwordIterations;
+		unsigned char passwordSalt[32];
+		uint32_t keyMaterialOffset;
+		uint32_t stripes;
+} __attribute__ ((packed));
+
+struct luks_header {
+	char		magic[6];	/* "LUKS\xba\xbe" */
+	uint16_t	version;	/* 1 */
+	char		cipherName[32];
+	char		cipherMode[32];
+	char		hashSpec[32];
+	uint32_t	payloadOffset;
+	uint32_t	keyBytes;
+	char		mkDigest[20];
+	unsigned char	mkDigestSalt[32];
+	uint32_t	mkDigestIterations;
+	char		uuid[40];
+
+	struct luks_keyslot_header ksh[LUKS_NUMKEYS];
+} __attribute__ ((packed));
+
+// FIXME: no return value checking
+// FIXME: too many static buffers
+
+static void sha1_buf(unsigned char *src, unsigned char *dst,
+		     uint32_t iv, int len)
+{
+	gcry_md_hd_t hd;
+	unsigned char *digest;
+
+	iv = htonl(iv);
+	gcry_md_open(&hd, GCRY_MD_SHA1, 0);
+	gcry_md_write(hd, (unsigned char *)&iv, sizeof(iv));
+	gcry_md_write(hd, src, len);
+	digest = gcry_md_read(hd, GCRY_MD_SHA1);
+	memcpy(dst, digest, len);
+	gcry_md_close(hd);
+}
+
+static void diffuse_g(unsigned char *src, unsigned char *dst, size_t size)
+{
+	unsigned int i, blocks, padding;
+
+	blocks = size / SHA1_DIGEST_SIZE;
+	padding = size % SHA1_DIGEST_SIZE;
+
+	if (gcry_md_get_algo_dlen (GCRY_MD_SHA1) != SHA1_DIGEST_SIZE)
+		return;
+
+	for (i = 0; i < blocks; i++)
+		sha1_buf(src + SHA1_DIGEST_SIZE * i,
+			 dst + SHA1_DIGEST_SIZE * i,
+			 i, SHA1_DIGEST_SIZE);
+
+	if(padding)
+		sha1_buf(src + SHA1_DIGEST_SIZE * i,
+			 dst + SHA1_DIGEST_SIZE * i,
+			 i, padding);
+}
+
+static int AF_merge_g(char *src, char *dst, size_t blocksize, unsigned int blocknumbers)
+{
+	unsigned int i, j;
+	unsigned char *buf;
+
+	if (!(buf = malloc(blocksize)))
+		return 1;
+
+	memset(buf, 0, blocksize);
+
+	for(i = 0; i < blocknumbers - 1; i++) {
+		for(j = 0; j < blocksize; j++)
+			buf[j] ^= src[blocksize * i + j];
+		diffuse_g(buf, buf, blocksize);
+	}
+
+	for(j = 0; j < blocksize; j++)
+		dst[j] = src[blocksize * i + j] ^ buf[j];
+
+	free(buf);
+	return 0;
+}
+
+/*
+ * DM helpers for temporary cryptsetup device
+ */
+// FIXME: this is stupid, we should have such funcions in library
+// Cannot use lvm helprs, library must be independend of lvm code
+// only libdevmapper calls possible here
+
+//FIXME: no uuid set for the temporary device
+
+static int _dm_simple(int task, const char *name)
+{
+	int r = 0;
+	struct dm_task *dmt;
+
+	if (!(dmt = dm_task_create(task)))
+		return 0;
+
+	if (!dm_task_set_name(dmt, name))
+		goto out;
+
+	r = dm_task_run(dmt);
+
+out:
+	dm_task_destroy(dmt);
+	return r;
+}
+
+static int _error_device(const char *name, size_t size)
+{
+	struct dm_task *dmt;
+	int r = 0;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_RELOAD)))
+		return 0;
+
+	if (!dm_task_set_name(dmt, name))
+		goto error;
+
+	if (!dm_task_add_target(dmt, UINT64_C(0), size, "error", ""))
+		goto error;
+
+	if (!dm_task_set_ro(dmt))
+		goto error;
+
+	if (!dm_task_no_open_count(dmt))
+		goto error;
+
+	if (!dm_task_run(dmt))
+		goto error;
+
+	if (!_dm_simple(DM_DEVICE_RESUME, name)) {
+		_dm_simple(DM_DEVICE_CLEAR, name);
+		goto error;
+	}
+
+	r = 1;
+error:
+	dm_task_destroy(dmt);
+	return r;
+}
+
+static int dm_create_device(const char *name, char *params, size_t size, const char *target)
+{
+	struct dm_task *dmt = NULL;
+	int r = 0;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_CREATE)))
+		return 0;
+	if (!dm_task_set_name(dmt, name))
+		goto out;
+	if (!dm_task_set_ro(dmt))
+                goto out;
+	if (!dm_task_add_target(dmt, 0, size, target, params))
+		goto out;
+	if (!dm_task_run(dmt))
+		goto out;
+	r = 1;
+	dm_task_update_nodes();
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
+static int dm_remove_device(const char *name, size_t size)
+{
+	int r = -EINVAL;
+	int retries = 2;
+
+	 _error_device(name, size);
+
+again:
+	r = _dm_simple(DM_DEVICE_REMOVE, name);
+
+	if (!r && --retries) {
+		sleep(1);
+		goto again;
+	}
+
+	dm_task_update_nodes();
+
+	return r;
+}
+
+static int read_keyslot_dev(const char *name, char *buffer, size_t len)
+{
+	char path[PATH_MAX+1];
+	struct device *dev;
+	int r = 1;
+
+	if (dm_snprintf(path, PATH_MAX, "%s/%s", dm_dir(), name) < 0) {
+		log_error("dm_snprintf failed");
+		return 0;
+	}
+
+	if (!(dev = dev_create_file(path, NULL, NULL, 1)))
+		return 0;
+
+	if (!dev_open(dev))
+		return 0;
+
+	/*
+	 * Trick to disable aligning to PAGE_SIZE and out of device access
+	 */
+	dev->flags &= ~DEV_REGULAR;
+
+	if (!dev_read(dev, 0, len, buffer))
+		r = 0;
+
+	if (!dev_close(dev))
+		stack;
+
+	return r;
+}
+
+static void key_to_hexa(char *key, char *hexakey, unsigned len)
+{
+	int i;
+
+	for(i = 0; i < len; i++)
+		sprintf(&hexakey[i * 2], "%02x", (unsigned char)key[i]);
+}
+
+static int luks_query_keyslots(struct device_area *da, struct luks_header *lh, const char *password, char *buffer, unsigned buffer_len)
+{
+	int i;
+	struct luks_keyslot_header *ksh;
+	unsigned key_len = ntohl(lh->keyBytes);
+	char keyslot_key[2048];
+	char keyslot_hexakey[2048];
+	char params[4096];
+	char hash_buf[SHA1_DIGEST_SIZE + 1];
+
+	char *keyslot = NULL;
+
+	// FIXME: cannot use fixed device name here
+	const char *dev_tmp = "lvm_luks1_keystore";
+	size_t dev_tmp_size, dev_tmp_sectors;
+	int r = 0;
+
+	memset(keyslot_key, 0, sizeof(keyslot_key));
+
+	// FIXME: with dm-crypt multiple segment trick this can be done in one step!
+	// FIXME: it keeps some sensitive data not wiped now in memory
+	for(i = 0; r == 0 && i < LUKS_NUMKEYS && (ksh = &lh->ksh[i]); i++) {
+		if (ntohl(ksh->active) != LUKS_KEY_ENABLED)
+			continue;
+		log_debug("Scanning active keyslot %u", i);
+
+		pkcs5_pbkdf2(GCRY_MD_SHA1, password, strlen(password),
+			     ksh->passwordSalt, sizeof(ksh->passwordSalt),
+			     ntohl(ksh->passwordIterations),
+			     key_len, keyslot_key);
+
+		key_to_hexa(keyslot_key, keyslot_hexakey, strlen(keyslot_key));
+
+		// <cipher> <key> <iv_offset> <device path> <offset>
+		// FIXME - skip ignored
+		sprintf(params, "%s-%s %s 0 %s %" PRIu64,
+			lh->cipherName, lh->cipherMode,
+			keyslot_hexakey, dev_name(da->dev), (da->start >> SECTOR_SHIFT) + ntohl(ksh->keyMaterialOffset));
+
+		dev_tmp_size = dm_round_up(ntohl(ksh->stripes) * key_len, (1 << SECTOR_SHIFT));
+		dev_tmp_sectors = dev_tmp_size >> SECTOR_SHIFT;
+
+		if (!dm_create_device(&dev_tmp[0], params, dev_tmp_sectors, "crypt"))
+			break;
+
+		if (!(keyslot = dm_malloc(dev_tmp_size)))
+			break;
+
+		if (!read_keyslot_dev(&dev_tmp[0], keyslot, dev_tmp_size))
+			break;
+
+		if (!dm_remove_device(&dev_tmp[0], dev_tmp_sectors))
+			break;
+
+		memset(keyslot_key, 0, sizeof(keyslot_key));
+		if (AF_merge_g(keyslot, keyslot_key, key_len, ntohl(ksh->stripes)) < 0)
+			break;
+
+		pkcs5_pbkdf2(GCRY_MD_SHA1, keyslot_key, key_len,
+				 lh->mkDigestSalt, sizeof(lh->mkDigestSalt),
+				 ntohl(lh->mkDigestIterations),
+				 SHA1_DIGEST_SIZE, hash_buf);
+
+		if (memcmp(hash_buf, lh->mkDigest, SHA1_DIGEST_SIZE) == 0) {
+			log_debug("Using valid key for slot %u", i);
+			key_to_hexa(keyslot_key, buffer, key_len);
+			r = 1;
+		}
+
+		memset(keyslot_key, 0, sizeof(keyslot_key));
+		memset(keyslot, 0, dev_tmp_size);
+		dm_free(keyslot);
+		keyslot = NULL;
+	}
+
+	return r;
+}
+
+static int ask_for_luks_password(const char *device_name,
+				 char *buffer, unsigned buffer_len)
+{
+	char prompt[4096];
+
+	dm_snprintf(prompt, sizeof(prompt), "Enter LUKS password%s%s : ",
+		    device_name ?" for ":"", device_name ?: "");
+
+	return lvm_read_password(prompt, buffer, buffer_len);
+}
+
+static int read_header(struct device_area *da, struct luks_header *lh)
+{
+	int r = 1;
+
+	if (sizeof(*lh) > da->size) {
+		log_error("LUKS1 internal error - keystore area too small.");
+		return 0;
+	}
+
+	if (!dev_open(da->dev)) {
+		log_error("Failed to open device %s.", dev_name(da->dev));
+		return 0;
+	}
+
+	if (!dev_read(da->dev, da->start, sizeof(*lh), (char*)lh)) {
+		log_error("Failed to read LUKS header from %s.",
+			  dev_name(da->dev));
+		r = 0;
+	}
+
+	if (!dev_close(da->dev))
+		stack;
+
+	return r;
+}
+
+static int header_compatible(struct luks_header *lh)
+{
+	if (strncmp(lh->magic, LUKS_MAGIC, sizeof(lh->magic)))
+		return 0;
+
+	if (ntohs(lh->version) != 1 || strcmp(lh->hashSpec, "sha1"))
+		return 0;
+
+	return 1;
+}
+
+static int luks1_scan(struct device_area *da)
+{
+	struct luks_header lh;
+
+	log_debug("Scanning for LUKS on device %s, offset %llu",
+		  dev_name(da->dev), da->start);
+
+	if (!read_header(da, &lh))
+		return 0;
+
+	if (!header_compatible(&lh)) {
+		log_verbose("Compatible LUKS1 header not found on device %s",
+			    dev_name(da->dev));
+		return 0;
+	}
+
+	if (ntohl(lh.payloadOffset) != da->size) {
+		log_verbose("LUKS1 data area is not aligned to requested offset.\n"
+			    "Data on device %s cannot be directly imported.",
+			    dev_name(da->dev));
+		return 0;
+	}
+
+	log_debug("Compatible LUKS1 header found on device %s, offset %llu",
+		  dev_name(da->dev), da->start);
+
+	return 1;
+}
+
+static int luks1_retrieve(struct crypto_store *cs, const char *for_text, char *buffer, unsigned buffer_len)
+{
+	char password[4096];
+	char cipher[1024];
+	unsigned password_len = sizeof(password);
+	struct device_area *da = first_crypto_area(cs);
+	struct luks_header lh;
+	int r;
+
+	log_debug("Retrieving key from LUKS1 keystore on device %s, offset %llu",
+		  dev_name(da->dev), da->start);
+
+	if (!read_header(da, &lh))
+		return_0;
+
+	if (!header_compatible(&lh)) {
+		log_error("Internal error: LUKS1 keystore area on device %s"
+			  "is corrupted or not compatible.", dev_name(da->dev));
+		return_0;
+	}
+
+	if (!ask_for_luks_password(for_text, password, password_len)) {
+		log_error("No password received.");
+		return 0;
+	}
+
+	r = luks_query_keyslots(da, &lh, password, buffer, buffer_len);
+	memset(password, 0, sizeof(password));
+	if (!r) {
+		log_error("No valid key found.");
+		return 0;
+	}
+
+	sprintf(cipher, "%s-%s", lh.cipherName, lh.cipherMode);
+	cs->cipher = dm_pool_strdup(cs->mem, cipher);
+	cs->key_size = ntohl(lh.keyBytes) * 8;
+
+	return 1;
+}
+
+static struct crypto_store_ops _luks1_ops = {
+	.scan = luks1_scan,
+	.master_key_retrieve = luks1_retrieve,
+};
+
+static struct crypto_store_type _luks1_csh = {
+	.name = "luks1",
+	.flags = CS_IGNORE_CIPHER | CS_IGNORE_KEYLEN | CS_IGNORE_KEYHASH,
+	.ops = &_luks1_ops,
+};
+
+struct crypto_store_type *keystore_luks1_init()
+{
+	//FIXME: Just for test - libgcrypt initialization
+	gcry_control(GCRYCTL_DISABLE_SECMEM, 0);
+	gcry_control(GCRYCTL_INITIALIZATION_FINISHED, 0);
+
+	return &_luks1_csh;
+}
diff --git a/lib/crypt/lvm-crypto.h b/lib/crypt/lvm-crypto.h
index 42004b7..928ff5b 100644
--- a/lib/crypt/lvm-crypto.h
+++ b/lib/crypt/lvm-crypto.h
@@ -107,6 +107,9 @@ int lvm_masterkeys_retrieve(const char *for_text, struct crypto_store *cs);
 int lvm_keystore_handlers_init(void);
 void lvm_keystore_handlers_destroy(void);
 struct crypto_store_type *lvm_get_keystore_handler(const char *name);
+#ifdef CRYPT_LUKS1
+struct crypto_store_type *keystore_luks1_init(void);
+#endif
 
 /*
  * Crypto Helper functions
diff --git a/lib/crypt/pbkdf2.c b/lib/crypt/pbkdf2.c
new file mode 100644
index 0000000..b9ce46c
--- /dev/null
+++ b/lib/crypt/pbkdf2.c
@@ -0,0 +1,199 @@
+/* Implementation of Password-Based Cryptography as per PKCS#5
+ * Copyright (C) 2002,2003 Simon Josefsson
+ * Copyright (C) 2004 Free Software Foundation
+ *
+ * This file is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU Lesser General Public
+ * License as published by the Free Software Foundation; either
+ * version 2.1 of the License, or (at your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * Lesser General Public License for more details.
+ *
+ * You should have received a copy of the GNU Lesser General Public
+ * License along with this file; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#include "pbkdf2.h"
+
+/*
+ * 5.2 PBKDF2
+ *
+ *  PBKDF2 applies a pseudorandom function (see Appendix B.1 for an
+ *  example) to derive keys. The length of the derived key is essentially
+ *  unbounded. (However, the maximum effective search space for the
+ *  derived key may be limited by the structure of the underlying
+ *  pseudorandom function. See Appendix B.1 for further discussion.)
+ *  PBKDF2 is recommended for new applications.
+ *
+ *  PBKDF2 (P, S, c, dkLen)
+ *
+ *  Options:        PRF        underlying pseudorandom function (hLen
+ *                             denotes the length in octets of the
+ *                             pseudorandom function output)
+ *
+ *  Input:          P          password, an octet string (ASCII or UTF-8)
+ *                  S          salt, an octet string
+ *                  c          iteration count, a positive integer
+ *                  dkLen      intended length in octets of the derived
+ *                             key, a positive integer, at most
+ *                             (2^32 - 1) * hLen
+ *
+ *  Output:         DK         derived key, a dkLen-octet string
+ */
+
+#define MAX_PRF_BLOCK_LEN 80
+
+int pkcs5_pbkdf2(int PRF,
+		     const char *P,
+		     size_t Plen,
+		     const unsigned char *S,
+		     size_t Slen, unsigned int c, unsigned int dkLen,
+		     char *DK)
+{
+    gcry_md_hd_t prf;
+    gcry_error_t err;
+    char U[MAX_PRF_BLOCK_LEN];
+    char T[MAX_PRF_BLOCK_LEN];
+    unsigned int u;
+    unsigned int hLen = gcry_md_get_algo_dlen(PRF);
+    unsigned int l;
+    unsigned int r;
+    int rc;
+    unsigned char *p;
+    int i;
+    int k;
+
+    if (hLen == 0 || hLen > MAX_PRF_BLOCK_LEN)
+	return PKCS5_INVALID_PRF;
+
+    if (c == 0)
+	return PKCS5_INVALID_ITERATION_COUNT;
+
+    if (dkLen == 0)
+	return PKCS5_INVALID_DERIVED_KEY_LENGTH;
+
+    /*
+     *
+     *  Steps:
+     *
+     *     1. If dkLen > (2^32 - 1) * hLen, output "derived key too long" and
+     *        stop.
+     */
+
+    if (dkLen > 4294967295U)
+	return PKCS5_DERIVED_KEY_TOO_LONG;
+
+    /*
+     *     2. Let l be the number of hLen-octet blocks in the derived key,
+     *        rounding up, and let r be the number of octets in the last
+     *        block:
+     *
+     *                  l = CEIL (dkLen / hLen) ,
+     *                  r = dkLen - (l - 1) * hLen .
+     *
+     *        Here, CEIL (x) is the "ceiling" function, i.e. the smallest
+     *        integer greater than, or equal to, x.
+     */
+
+    l = dkLen / hLen;
+    if (dkLen % hLen)
+	l++;
+    r = dkLen - (l - 1) * hLen;
+
+    /*
+     *     3. For each block of the derived key apply the function F defined
+     *        below to the password P, the salt S, the iteration count c, and
+     *        the block index to compute the block:
+     *
+     *                  T_1 = F (P, S, c, 1) ,
+     *                  T_2 = F (P, S, c, 2) ,
+     *                  ...
+     *                  T_l = F (P, S, c, l) ,
+     *
+     *        where the function F is defined as the exclusive-or sum of the
+     *        first c iterates of the underlying pseudorandom function PRF
+     *        applied to the password P and the concatenation of the salt S
+     *        and the block index i:
+     *
+     *                  F (P, S, c, i) = U_1 \xor U_2 \xor ... \xor U_c
+     *
+     *        where
+     *
+     *                  U_1 = PRF (P, S || INT (i)) ,
+     *                  U_2 = PRF (P, U_1) ,
+     *                  ...
+     *                  U_c = PRF (P, U_{c-1}) .
+     *
+     *        Here, INT (i) is a four-octet encoding of the integer i, most
+     *        significant octet first.
+     *
+     *     4. Concatenate the blocks and extract the first dkLen octets to
+     *        produce a derived key DK:
+     *
+     *                  DK = T_1 || T_2 ||  ...  || T_l<0..r-1>
+     *
+     *     5. Output the derived key DK.
+     *
+     *  Note. The construction of the function F follows a "belt-and-
+     *  suspenders" approach. The iterates U_i are computed recursively to
+     *  remove a degree of parallelism from an opponent; they are exclusive-
+     *  ored together to reduce concerns about the recursion degenerating
+     *  into a small set of values.
+     *
+     */
+
+    err = gcry_md_open(&prf, PRF, GCRY_MD_FLAG_HMAC);
+    if (err)
+	return PKCS5_INVALID_PRF;
+
+    for (i = 1; (uint) i <= l; i++) {
+	memset(T, 0, hLen);
+
+	for (u = 1; u <= c; u++) {
+	    gcry_md_reset(prf);
+
+	    rc = gcry_md_setkey(prf, P, Plen);
+	    if (rc)
+		return PKCS5_INVALID_PRF;
+
+	    if (u == 1) {
+		char *tmp;
+		size_t tmplen = Slen + 4;
+
+		tmp = alloca(tmplen);
+		if (tmp == NULL)
+		    return PKCS5_INVALID_PRF;
+
+		memcpy(tmp, S, Slen);
+		tmp[Slen + 0] = (i & 0xff000000) >> 24;
+		tmp[Slen + 1] = (i & 0x00ff0000) >> 16;
+		tmp[Slen + 2] = (i & 0x0000ff00) >> 8;
+		tmp[Slen + 3] = (i & 0x000000ff) >> 0;
+
+		gcry_md_write(prf, tmp, tmplen);
+	    } else {
+		gcry_md_write(prf, U, hLen);
+	    }
+
+	    p = gcry_md_read(prf, PRF);
+	    if (p == NULL)
+		return PKCS5_INVALID_PRF;
+
+	    memcpy(U, p, hLen);
+
+	    for (k = 0; (uint) k < hLen; k++)
+		T[k] ^= U[k];
+	}
+
+	memcpy(DK + (i - 1) * hLen, T, (uint) i == l ? r : hLen);
+    }
+
+    gcry_md_close(prf);
+
+    return PKCS5_OK;
+}
diff --git a/lib/crypt/pbkdf2.h b/lib/crypt/pbkdf2.h
new file mode 100644
index 0000000..3b6cc8e
--- /dev/null
+++ b/lib/crypt/pbkdf2.h
@@ -0,0 +1,36 @@
+/*
+ * pkcs5_pbkdf2 implementation
+ *
+ * Copyright (C) 2002 Simon Josefsson
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
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
+#ifndef PBKDF2_H
+#define PBKDF2_H
+
+#include <gcrypt.h>
+
+/* Error codes */
+enum {
+  PKCS5_OK = 0,
+  PKCS5_INVALID_PRF,
+  PKCS5_INVALID_ITERATION_COUNT,
+  PKCS5_INVALID_DERIVED_KEY_LENGTH,
+  PKCS5_DERIVED_KEY_TOO_LONG
+};
+
+int pkcs5_pbkdf2(int PRF, const char *P, size_t Plen,
+		 const unsigned char *S, size_t Slen,
+		 unsigned int c, unsigned int dkLen, char *DK);
+
+#endif /* PBKDF2_H */
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index d171445..1150b34 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -14,6 +14,9 @@
 /* Define to 1 to include built-in support for crypto. */
 #undef CRYPT_INTERNAL
 
+/* Define to 1 to include built-in support for LUKS1 keystore. */
+#undef CRYPT_LUKS1
+
 /* Define to 1 if using `alloca.c'. */
 #undef C_ALLOCA
 
-- 
1.5.6.5


