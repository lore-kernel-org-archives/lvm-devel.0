From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:05 +0000 (UTC)
Subject: master - memlock: ignore more libraries
Message-ID: <20140414110605.8BF9B609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd3e44643de16ba0171af05413626a55a0a51b42
Commit:        bd3e44643de16ba0171af05413626a55a0a51b42
Parent:        84ff3ae703ec7d2859398f01eee726134c543723
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 10 10:52:44 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 12:53:07 2014 +0200

memlock: ignore more libraries

Extend the list of ignored libraries. Since we do not
use those libraries during suspend, skip their locking.
---
 WHATS_NEW        |    1 +
 lib/mm/memlock.c |    8 +++++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e7e74ed..4a35b7e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Skip more libraries to be mlocked in memory.
   Remove LOCKED flag for pvmove replaced with error target.
   Return invalid command when specifying negative polling interval.
 
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index e626a6a..153ae17 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -92,9 +92,15 @@ static const char * const _blacklist_maps[] = {
     "locale/locale-archive",
     "/LC_MESSAGES/",
     "gconv/gconv-modules.cache",
-    "/libreadline.so.",	/* not using readline during mlock */
+    "/libblkid.so.",	/* not using lzma during mlock (selinux) */
+    "/liblzma.so.",	/* not using lzma during mlock (selinux) */
     "/libncurses.so.",	/* not using ncurses during mlock */
+    "/libpcre.so.",	/* not using pcre during mlock (selinux) */
+    "/libreadline.so.",	/* not using readline during mlock */
+    "/libselinux.so.",	/* not using selinux during mlock */
+    "/libsepol.so.",	/* not using sepol during mlock */
     "/libtinfo.so.",	/* not using tinfo during mlock */
+    "/libuuid.so.",	/* not using uuid during mlock (blkid) */
     "/libdl-",		/* not using dlopen,dlsym during mlock */
     /* "/libdevmapper-event.so" */
 };


