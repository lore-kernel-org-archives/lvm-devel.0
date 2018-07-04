From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 4 Jul 2018 07:42:21 -0400
Subject: 2018-06-01-stable - memlock: extend exception list
Message-ID: <201807041142.w64BgLGY019181@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df8eef70961686c32e7409551d9c2633eb629fc9
Commit:        df8eef70961686c32e7409551d9c2633eb629fc9
Parent:        c1dbb22ba44460bf75c2dc7c0f72434abab40219
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 30 11:05:14 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 4 13:41:08 2018 +0200

memlock: extend exception list

Amound of linked libraries grows.
Most of them we don't need to lock in, since we are not using
them in locked section, so skip locking them in memory.
---
 WHATS_NEW        |    1 +
 lib/mm/memlock.c |   19 +++++++++++++------
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ff0746e..99dc056 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.180 - 
 =================================
+  Extend list of non-memlocked areas with newly linked libs.
   Enhance vgcfgrestore to check for active LVs in restored VG.
   lvconvert: provide possible layouts between linear and striped/raid
   Fix unmonitoring of merging snapshots.
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index b15058e..c8e6ef1 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -105,23 +105,30 @@ static const char * const _blacklist_maps[] = {
 	"/LC_MESSAGES/",
 	"gconv/gconv-modules.cache",
 	"/ld-2.",		/* not using dlopen,dlsym during mlock */
+	"/libaio.so.",		/* not using aio during mlock */
 	"/libattr.so.",		/* not using during mlock (udev) */
-	"/libblkid.so.",	/* not using lzma during mlock (selinux) */
+	"/libblkid.so.",	/* not using blkid during mlock (udev) */
 	"/libbz2.so.",		/* not using during mlock (udev) */
-	"/libcap.so.",		/* not using during mlock (udev) */
+	"/libcap.so.",		/* not using during mlock (systemd) */
+	"/libdl-",		/* not using dlopen,dlsym during mlock */
 	"/libdw-",		/* not using during mlock (udev) */
 	"/libelf-",		/* not using during mlock (udev) */
-	"/liblzma.so.",	/* not using lzma during mlock (selinux) */
+	"/libgcrypt.so.",	/* not using during mlock (systemd) */
+	"/libgpg-error.so.",	/* not using gpg-error during mlock (systemd) */
+	"/liblz4.so.",		/* not using lz4 during mlock (systemd) */
+	"/liblzma.so.",		/* not using lzma during mlock (systemd) */
+	"/libmount.so.",	/* not using mount during mlock (udev) */
 	"/libncurses.so.",	/* not using ncurses during mlock */
-	"/libpcre.so.",	/* not using pcre during mlock (selinux) */
+	"/libpcre.so.",		/* not using pcre during mlock (selinux) */
+	"/libpcre2-",		/* not using pcre during mlock (selinux) */
 	"/libreadline.so.",	/* not using readline during mlock */
-	"/libresolv-",	/* not using during mlock (udev) */
+	"/libresolv-",		/* not using during mlock (udev) */
 	"/libselinux.so.",	/* not using selinux during mlock */
 	"/libsepol.so.",	/* not using sepol during mlock */
+	"/libsystemd.so.",	/* not using systemd during mlock */
 	"/libtinfo.so.",	/* not using tinfo during mlock */
 	"/libudev.so.",		/* not using udev during mlock */
 	"/libuuid.so.",		/* not using uuid during mlock (blkid) */
-	"/libdl-",		/* not using dlopen,dlsym during mlock */
 	"/libz.so.",		/* not using during mlock (udev) */
 	"/etc/selinux",		/* not using selinux during mlock */
 	/* "/libdevmapper-event.so" */


