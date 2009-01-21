From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:47 +0100
Subject: [PATCH 06/15] Prepare source for recognising crypt segment.
In-Reply-To: <3417d8a2769cc152bd8aef5921716b693360ee15.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
	<1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
	<589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
	<b43d35ebbdda1be4696b072c222c243cb0645f72.1232488181.git.mbroz@redhat.com>
	<3417d8a2769cc152bd8aef5921716b693360ee15.1232488181.git.mbroz@redhat.com>
Message-ID: <6d887c3c90806a55ac1cf569425845ce0ed16daa.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 - modify autoconf script to define CRYPTO
   (supporting currently only --with-crypto=none/internal)
   and add CRYPT_INTERNAL define

 - prepare empty segtype constructors
   for segtype "crypt" (encrypted area)
   for segtype "crypt-keystore" (crypto metadata area)

 - define new encrypted segment flag and prepare
   macros to work with it.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 configure                  |   39 +++++++++++++++++++++++++++++++++++++--
 configure.in               |   21 +++++++++++++++++++++
 lib/Makefile.in            |    4 ++++
 lib/commands/toolcontext.c |   13 +++++++++++++
 lib/crypt/crypt.c          |   44 ++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/segtype.h     |    6 ++++++
 lib/misc/configure.h.in    |    3 +++
 7 files changed, 128 insertions(+), 2 deletions(-)
 create mode 100644 lib/crypt/crypt.c

diff --git a/configure b/configure
index 8095090..e4a8f82 100755
--- a/configure
+++ b/configure
@@ -699,6 +699,7 @@ CLUSTER
 CLVMD
 CMDLIB
 COPTIMISE_FLAG
+CRYPTO
 DEBUG
 DEVMAPPER
 DMEVENTD
@@ -1360,6 +1361,8 @@ Optional Packages:
                           TYPE=internal
   --with-mirrors=TYPE     Mirror support: internal/shared/none
                           TYPE=internal
+  --with-crypto=TYPE      Crypto support: internal/none
+                          TYPE=internal
   --with-clvmd=TYPE       Build cluster LVM Daemon: cman/gulm/none/all
                           TYPE=none
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
@@ -8663,6 +8666,36 @@ _ACEOF
 fi
 
 ################################################################################
+{ echo "$as_me:$LINENO: checking whether to include crypto support" >&5
+echo $ECHO_N "checking whether to include crypto support... $ECHO_C" >&6; }
+
+# Check whether --with-crypto was given.
+if test "${with_crypto+set}" = set; then
+  withval=$with_crypto;  CRYPTO="$withval"
+else
+   CRYPTO="internal"
+fi
+
+{ echo "$as_me:$LINENO: result: $CRYPTO" >&5
+echo "${ECHO_T}$CRYPTO" >&6; }
+
+if [ "x$CRYPTO" != xnone -a "x$CRYPTO" != xinternal ];
+ then  { { echo "$as_me:$LINENO: error: --with-crypto parameter invalid
+" >&5
+echo "$as_me: error: --with-crypto parameter invalid
+" >&2;}
+   { (exit 1); exit 1; }; }
+fi;
+
+if test x$CRYPTO = xinternal; then
+
+cat >>confdefs.h <<\_ACEOF
+#define CRYPT_INTERNAL 1
+_ACEOF
+
+fi
+
+################################################################################
 { echo "$as_me:$LINENO: checking whether to enable readline" >&5
 echo $ECHO_N "checking whether to enable readline... $ECHO_C" >&6; }
 # Check whether --enable-readline was given.
@@ -11719,6 +11752,7 @@ LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile tools/version.h"
 
@@ -12450,6 +12484,7 @@ CLUSTER!$CLUSTER$ac_delim
 CLVMD!$CLVMD$ac_delim
 CMDLIB!$CMDLIB$ac_delim
 COPTIMISE_FLAG!$COPTIMISE_FLAG$ac_delim
+CRYPTO!$CRYPTO$ac_delim
 DEBUG!$DEBUG$ac_delim
 DEVMAPPER!$DEVMAPPER$ac_delim
 DMEVENTD!$DMEVENTD$ac_delim
@@ -12461,7 +12496,6 @@ DM_IOCTLS!$DM_IOCTLS$ac_delim
 DM_LIB_VERSION!$DM_LIB_VERSION$ac_delim
 DM_LIB_PATCHLEVEL!$DM_LIB_PATCHLEVEL$ac_delim
 FSADM!$FSADM$ac_delim
-GROUP!$GROUP$ac_delim
 _ACEOF
 
   if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 97; then
@@ -12503,6 +12537,7 @@ _ACEOF
 ac_delim='%!_!# '
 for ac_last_try in false false false false false :; do
   cat >conf$$subs.sed <<_ACEOF
+GROUP!$GROUP$ac_delim
 HAVE_LIBDL!$HAVE_LIBDL$ac_delim
 HAVE_REALTIME!$HAVE_REALTIME$ac_delim
 HAVE_SELINUX!$HAVE_SELINUX$ac_delim
@@ -12534,7 +12569,7 @@ usrsbindir!$usrsbindir$ac_delim
 LTLIBOBJS!$LTLIBOBJS$ac_delim
 _ACEOF
 
-  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 29; then
+  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 30; then
     break
   elif $ac_last_try; then
     { { echo "$as_me:$LINENO: error: could not make $CONFIG_STATUS" >&5
diff --git a/configure.in b/configure.in
index 5d28c2c..a5e9236 100644
--- a/configure.in
+++ b/configure.in
@@ -306,6 +306,26 @@ if test x$MIRRORS = xinternal; then
 fi
 
 ################################################################################
+dnl -- crypt inclusion type
+AC_MSG_CHECKING(whether to include crypto support)
+AC_ARG_WITH(crypto,
+  [  --with-crypto=TYPE      Crypto support: internal/none
+                          [TYPE=internal] ],
+  [ CRYPTO="$withval" ],
+  [ CRYPTO="internal" ])
+AC_MSG_RESULT($CRYPTO)
+
+if [[ "x$CRYPTO" != xnone -a "x$CRYPTO" != xinternal ]];
+ then  AC_MSG_ERROR(
+--with-crypto parameter invalid
+)
+fi;
+
+if test x$CRYPTO = xinternal; then
+	AC_DEFINE([CRYPT_INTERNAL], 1, [Define to 1 to include built-in support for crypto.])
+fi
+
+################################################################################
 dnl -- Disable readline
 AC_MSG_CHECKING(whether to enable readline)
 AC_ARG_ENABLE([readline],
@@ -734,6 +754,7 @@ AC_SUBST(CLUSTER)
 AC_SUBST(CLVMD)
 AC_SUBST(CMDLIB)
 AC_SUBST(COPTIMISE_FLAG)
+AC_SUBST(CRYPTO)
 AC_SUBST(CSCOPE_CMD)
 AC_SUBST(DEBUG)
 AC_SUBST(DEVMAPPER)
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 41395ed..7971395 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -126,6 +126,10 @@ ifeq ("@MIRRORS@", "internal")
   SOURCES += mirror/mirrored.c
 endif
 
+ifeq ("@CRYPTO@", "internal")
+  SOURCES += crypt/crypt.c
+endif
+
 ifeq ("@DEVMAPPER@", "yes")
   SOURCES +=\
 	activate/dev_manager.c \
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index f9a0b13..af7643b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -846,6 +846,19 @@ static int _init_segtypes(struct cmd_context *cmd)
 	dm_list_add(&cmd->segtypes, &segtype->list);
 #endif
 
+#ifdef CRYPT_INTERNAL
+	if (!(segtype = init_crypt_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	/* Keystore must be supported if crypt segment is present */
+	if (!(segtype = init_keystore_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+#endif
+
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs unless static */
 	if (!is_static() &&
diff --git a/lib/crypt/crypt.c b/lib/crypt/crypt.c
new file mode 100644
index 0000000..c6658c8
--- /dev/null
+++ b/lib/crypt/crypt.c
@@ -0,0 +1,44 @@
+/*
+ * Copyright (C) 2008-2009 Red Hat, Inc. All rights reserved.
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
+#include "lib.h"
+#include "segtype.h"
+#include "display.h"
+#include "text_export.h"
+#include "text_import.h"
+#include "str_list.h"
+#include "targets.h"
+#include "activate.h"
+#include "pv_alloc.h"
+#include "metadata.h"
+#include "toolcontext.h"
+#include "lvm-crypto.h"
+
+/*
+ * "crypt" segment - using real crypt target directly
+ */
+struct segment_type *init_crypt_segtype(struct cmd_context *cmd)
+{
+	return NULL;
+}
+
+/*
+ * "crypt-keystore" segment - area for storing keys, need specific handler
+ * (e.g. LUKS metadata space)
+ */
+
+struct segment_type *init_keystore_segtype(struct cmd_context *cmd)
+{
+	return NULL;
+}
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index ad274a3..15f4b5b 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -33,6 +33,7 @@ struct dev_manager;
 #define SEG_VIRTUAL		0x00000020U
 #define SEG_CANNOT_BE_ZEROED	0x00000040U
 #define SEG_MONITORED		0x00000080U
+#define SEG_AREAS_ENCRYPTED	0x00000100U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
@@ -41,10 +42,14 @@ struct dev_manager;
 #define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
+#define seg_is_encrypted(seg)	((seg)->segtype->flags & SEG_AREAS_ENCRYPTED ? 1 : 0)
+#define seg_is_keystore(seg)	(seg_is_encrypted(seg) && seg_cannot_be_zeroed(seg))
 
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
+#define segtype_is_encrypted(segtype)	((segtype)->flags & SEG_AREAS_ENCRYPTED ? 1 : 0)
+#define segtype_is_keystore(segtype)	(segtype_is_encrypted(segtype) && segtype_cannot_be_zeroed(segtype))
 
 struct segment_type {
 	struct dm_list list;
@@ -106,6 +111,7 @@ struct segment_type *init_mirrored_segtype(struct cmd_context *cmd);
 #endif
 
 #ifdef CRYPT_INTERNAL
+struct segment_type *init_keystore_segtype(struct cmd_context *cmd);
 struct segment_type *init_crypt_segtype(struct cmd_context *cmd);
 #endif
 
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index ccab9f5..d171445 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -11,6 +11,9 @@
    */
 #undef CRAY_STACKSEG_END
 
+/* Define to 1 to include built-in support for crypto. */
+#undef CRYPT_INTERNAL
+
 /* Define to 1 if using `alloca.c'. */
 #undef C_ALLOCA
 
-- 
1.5.6.5


