From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Dec 2015 19:17:17 +0000 (UTC)
Subject: master - fix static linking
Message-ID: <20151211191717.1FF8B6032D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a4badc07fbb864be3014c14e61e8c606593437d
Commit:        7a4badc07fbb864be3014c14e61e8c606593437d
Parent:        0688dbbc5303ee99709f202a023e7b96a515f6aa
Author:        Riku Voipio <riku.voipio@linaro.org>
AuthorDate:    Tue Dec 8 16:40:08 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 11 20:15:51 2015 +0100

fix static linking

Static linking fails currently, as -lm and -lpthread are missing:

gcc -O2  -fPIC -O2  -L../libdm -L../lib -L../libdaemon/client -static
-L../libdm/ioctl \
      -o dmsetup.static dmsetup.o -ldevmapper    -lrt
../libdm/ioctl/libdevmapper.a(libdm-stats.o): In function
`dm_stats_create_region':
libdm-stats.c:(.text+0x2d69): undefined reference to `log10'
libdm-stats.c:(.text+0x2d6e): undefined reference to `lround'
../libdm/ioctl/libdevmapper.a(pool.o): In function `dm_pool_create':
pool.c:(.text+0x134): undefined reference to `pthread_mutex_lock'
pool.c:(.text+0x14f): undefined reference to `pthread_mutex_unlock'

Signed-off-by: Riku Voipio <riku.voipio@linaro.org>
---
 WHATS_NEW_DM      |    1 +
 tools/Makefile.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f6e9d2a..c4d62e1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.114 -
 ====================================
+  Better support for dmsetup static linkage.
   Extend validity checks on dmeventd client socket.
 
 Version 1.02.113 - 5th December 2015
diff --git a/tools/Makefile.in b/tools/Makefile.in
index d6e54f0..518a21a 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -130,7 +130,7 @@ dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
 
 dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
-	      -o $@ dmsetup.o -ldevmapper $(STATIC_LIBS) $(LIBS)
+	      -o $@ dmsetup.o -ldevmapper $(M_LIBS) $(PTHREAD_LIBS) $(STATIC_LIBS) $(LIBS)
 
 all: device-mapper
 


