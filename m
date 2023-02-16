From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:53 +0000 (GMT)
Subject: main - configure.ac: remove unneded vars and settings
Message-ID: <20230216231053.0B9AE3858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1cd71a5fe3f69d0a4c8c05babd4a7433682318b5
Commit:        1cd71a5fe3f69d0a4c8c05babd4a7433682318b5
Parent:        bb4ed5c23d73ac5cfd2cba28147c1dc7df1de47d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 23:39:45 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:00:12 2023 +0100

configure.ac: remove unneded vars and settings

---
 configure.ac | 33 ---------------------------------
 1 file changed, 33 deletions(-)

diff --git a/configure.ac b/configure.ac
index 7ce4b8f6a..b728ad096 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1791,18 +1791,8 @@ LVM_LIBAPI=$(echo "$VER" | $AWK -F '[[()]]' '{print $2}')
 
 AC_DEFINE_UNQUOTED(LVM_CONFIGURE_LINE, "$CONFIGURE_LINE", [configure command line used])
 
-AC_ARG_VAR([BLKID_CFLAGS], [C compiler flags for blkid])
-AC_ARG_VAR([BLKID_LIBS], [linker flags for blkid])
-AC_ARG_VAR([CPG_CFLAGS], [C compiler flags for cpg])
-AC_ARG_VAR([CPG_LIBS], [linker flags for cpg])
-AC_ARG_VAR([EDITLINE_CFLAGS], [C compiler flags for editline])
-AC_ARG_VAR([EDITLINE_LIBS], [linker flags for editline])
 AC_ARG_VAR([READLINE_CFLAGS], [C compiler flags for readline])
 AC_ARG_VAR([READLINE_LIBS], [linker flags for readline])
-AC_ARG_VAR([SYSTEMD_CFLAGS], [C compiler flags for systemd])
-AC_ARG_VAR([SYSTEMD_LIBS], [linker flags for systemd])
-AC_ARG_VAR([UDEV_CFLAGS], [C compiler flags for udev])
-AC_ARG_VAR([UDEV_LIBS], [linker flags for udev])
 
 ################################################################################
 AC_SUBST(AWK)
@@ -1825,8 +1815,6 @@ AC_SUBST(CLDFLAGS)
 AC_SUBST(CLDNOWHOLEARCHIVE)
 AC_SUBST(CLDWHOLEARCHIVE)
 AC_SUBST(CMDLIB)
-AC_SUBST(CONFDB_CFLAGS)
-AC_SUBST(CONFDB_LIBS)
 AC_SUBST(CONFDIR)
 AC_SUBST(COPTIMISE_FLAG)
 AC_SUBST(CSCOPE_CMD)
@@ -1849,8 +1837,6 @@ AC_SUBST(DEFAULT_USE_DEVICES_FILE)
 AC_SUBST(DEFAULT_USE_LVMPOLLD)
 AC_SUBST(DEFAULT_USE_LVMLOCKD)
 AC_SUBST(DEVMAPPER)
-AC_SUBST(DLM_CFLAGS)
-AC_SUBST(DLM_LIBS)
 AC_SUBST(DL_LIBS)
 AC_SUBST(DMEVENTD_PATH)
 AC_SUBST(DM_LIB_PATCHLEVEL)
@@ -1859,11 +1845,6 @@ AC_SUBST(FSADM)
 AC_SUBST(FSADM_PATH)
 AC_SUBST(LVRESIZE_FS_HELPER_PATH)
 AC_SUBST(BLKDEACTIVATE)
-AC_SUBST(HAVE_BLKID)
-AC_SUBST(HAVE_BLKID_SUBLKS_FSINFO)
-AC_SUBST(HAVE_LIBDL)
-AC_SUBST(HAVE_REALTIME)
-AC_SUBST(HAVE_VALGRIND)
 AC_SUBST(INTEGRITY)
 AC_SUBST(INTL)
 AC_SUBST(JOBS)
@@ -1892,23 +1873,9 @@ AC_SUBST(M_LIBS)
 AC_SUBST(PTHREAD_LIBS)
 AC_SUBST(PYTHON2)
 AC_SUBST(PYTHON3)
-AC_SUBST(PYTHON_BINDINGS)
-AC_SUBST(PYTHON2_BINDINGS)
-AC_SUBST(PYTHON3_BINDINGS)
-AC_SUBST(PYTHON2_INCDIRS)
-AC_SUBST(PYTHON3_INCDIRS)
-AC_SUBST(PYTHON2_LIBDIRS)
-AC_SUBST(PYTHON3_LIBDIRS)
 AC_SUBST(PYTHON2DIR)
 AC_SUBST(PYTHON3DIR)
-AC_SUBST(QUORUM_CFLAGS)
-AC_SUBST(QUORUM_LIBS)
 AC_SUBST(RT_LIBS)
-AC_SUBST(REPLICATORS)
-AC_SUBST(SACKPT_CFLAGS)
-AC_SUBST(SACKPT_LIBS)
-AC_SUBST(SALCK_CFLAGS)
-AC_SUBST(SALCK_LIBS)
 AC_SUBST(SBINDIR)
 AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SELINUX_PC)

