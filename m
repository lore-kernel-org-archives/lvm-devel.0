From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 May 2010 16:14:55 +0200
Subject: [PATCH 8/9] Requires.private: update
In-Reply-To: <cover.1273241256.git.zkabelac@redhat.com>
References: <cover.1273241256.git.zkabelac@redhat.com>
Message-ID: <98a3240fac4752abd9d3be5fd14b27cecedac9e9.1273241256.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use Requires.private: instead of Libs.private:
Use UDEV_PC and SELINUX_PC for Require.private:

It looks like usage of Requires.private is prefered from Libs.private.
However pkg-config documentation is really poor here. But here is
short outcome:

There is a difference in Libs.private: and Requires.private: where
we specify libselinux instead of  -lselinux -lsepol
We essentially leave resolving of query  pkg-config --libs --static devmapper
on taking proper selinux and udev libs to their .pc files instead of
hardcoding them into our .pc file which is wrong - i.e. dependency of
libselinux package might change - but we may not return proper value for
static linking.

http://bugs.freedesktop.org/show_bug.cgi?id=4738
http://err.no/personal/blog/tech/2008-03-25-18-07_pkg-config,_sonames_and_Requires.private

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.pc.in |    2 +-
 liblvm/liblvm2app.pc.in  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.pc.in b/libdm/libdevmapper.pc.in
index 5910583..eb7071d 100644
--- a/libdm/libdevmapper.pc.in
+++ b/libdm/libdevmapper.pc.in
@@ -8,4 +8,4 @@ Description: device-mapper library
 Version: @DM_LIB_PATCHLEVEL@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -ldevmapper
-Libs.private: @SELINUX_LIBS@ @UDEV_LIBS@
+Requires.private: @SELINUX_PC@ @UDEV_PC@
diff --git a/liblvm/liblvm2app.pc.in b/liblvm/liblvm2app.pc.in
index 6bf8ecd..4c71c36 100644
--- a/liblvm/liblvm2app.pc.in
+++ b/liblvm/liblvm2app.pc.in
@@ -8,4 +8,4 @@ Description: lvm2 application library
 Version: @LVM_MAJOR at .@LVM_LIBAPI@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -llvm2app
-Libs.private: -ldevmapper
+Requires.private: devmapper
-- 
1.7.0.1


