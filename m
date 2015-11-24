From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 24 Nov 2015 10:33:15 +0000 (UTC)
Subject: master - memlock: add more libs on ignore list
Message-ID: <20151124103315.249DD610DF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15be97d76b0ca24d62c67a947ae595a2124260be
Commit:        15be97d76b0ca24d62c67a947ae595a2124260be
Parent:        6ca5447e0c65ba6126a005aafeff3dc5c340bb75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 22 00:26:06 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 23 23:39:01 2015 +0100

memlock: add more libs on ignore list

Udev recently start to 'link-in' major amount of useless libs.
(Seem to be faulty 'systemd' link-in all issue)
Anyway - avoid locking those libs in RAM.
---
 WHATS_NEW        |    1 +
 lib/mm/memlock.c |    8 ++++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f247487..0b24981 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.136 - 
 =====================================
+  Extend the list of ignored libraries when locking memory.
 
 Version 2.02.135 - 23rd November 2015
 =====================================
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index c17ae13..969f1d7 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -97,17 +97,25 @@ static const char * const _blacklist_maps[] = {
 	"locale/locale-archive",
 	"/LC_MESSAGES/",
 	"gconv/gconv-modules.cache",
+	"/ld-2.",		/* not using dlopen,dlsym during mlock */
+	"/libattr.so.",		/* not using during mlock (udev) */
 	"/libblkid.so.",	/* not using lzma during mlock (selinux) */
+	"/libbz2.so.",		/* not using during mlock (udev) */
+	"/libcap.so.",		/* not using during mlock (udev) */
+	"/libdw-",		/* not using during mlock (udev) */
+	"/libelf-",		/* not using during mlock (udev) */
 	"/liblzma.so.",	/* not using lzma during mlock (selinux) */
 	"/libncurses.so.",	/* not using ncurses during mlock */
 	"/libpcre.so.",	/* not using pcre during mlock (selinux) */
 	"/libreadline.so.",	/* not using readline during mlock */
+	"/libresolv-",	/* not using during mlock (udev) */
 	"/libselinux.so.",	/* not using selinux during mlock */
 	"/libsepol.so.",	/* not using sepol during mlock */
 	"/libtinfo.so.",	/* not using tinfo during mlock */
 	"/libudev.so.",		/* not using udev during mlock */
 	"/libuuid.so.",		/* not using uuid during mlock (blkid) */
 	"/libdl-",		/* not using dlopen,dlsym during mlock */
+	"/libz.so.",		/* not using during mlock (udev) */
 	"/etc/selinux",		/* not using selinux during mlock */
 	/* "/libdevmapper-event.so" */
 };


