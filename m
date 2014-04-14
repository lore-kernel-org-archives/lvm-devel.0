From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:26 +0000 (UTC)
Subject: master - cleanup: corrent indent level
Message-ID: <20140414110626.A59D160CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d803ee9806bc3838a515619bec211b9233d803e
Commit:        1d803ee9806bc3838a515619bec211b9233d803e
Parent:        d896abc705d8aedd1d74c6fc01985fc88e7e44ed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 14 11:20:20 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 13:02:28 2014 +0200

cleanup: corrent indent level

---
 lib/mm/memlock.c |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 153ae17..5382b69 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -82,27 +82,27 @@ static int _default_priority;
 
 /* list of maps, that are unconditionaly ignored */
 static const char * const _ignore_maps[] = {
-    "[vdso]",
-    "[vsyscall]",
-    "[vectors]",
+	"[vdso]",
+	"[vsyscall]",
+	"[vectors]",
 };
 
 /* default blacklist for maps */
 static const char * const _blacklist_maps[] = {
-    "locale/locale-archive",
-    "/LC_MESSAGES/",
-    "gconv/gconv-modules.cache",
-    "/libblkid.so.",	/* not using lzma during mlock (selinux) */
-    "/liblzma.so.",	/* not using lzma during mlock (selinux) */
-    "/libncurses.so.",	/* not using ncurses during mlock */
-    "/libpcre.so.",	/* not using pcre during mlock (selinux) */
-    "/libreadline.so.",	/* not using readline during mlock */
-    "/libselinux.so.",	/* not using selinux during mlock */
-    "/libsepol.so.",	/* not using sepol during mlock */
-    "/libtinfo.so.",	/* not using tinfo during mlock */
-    "/libuuid.so.",	/* not using uuid during mlock (blkid) */
-    "/libdl-",		/* not using dlopen,dlsym during mlock */
-    /* "/libdevmapper-event.so" */
+	"locale/locale-archive",
+	"/LC_MESSAGES/",
+	"gconv/gconv-modules.cache",
+	"/libblkid.so.",	/* not using lzma during mlock (selinux) */
+	"/liblzma.so.",	/* not using lzma during mlock (selinux) */
+	"/libncurses.so.",	/* not using ncurses during mlock */
+	"/libpcre.so.",	/* not using pcre during mlock (selinux) */
+	"/libreadline.so.",	/* not using readline during mlock */
+	"/libselinux.so.",	/* not using selinux during mlock */
+	"/libsepol.so.",	/* not using sepol during mlock */
+	"/libtinfo.so.",	/* not using tinfo during mlock */
+	"/libuuid.so.",	/* not using uuid during mlock (blkid) */
+	"/libdl-",		/* not using dlopen,dlsym during mlock */
+	/* "/libdevmapper-event.so" */
 };
 
 typedef enum { LVM_MLOCK, LVM_MUNLOCK } lvmlock_t;


