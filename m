From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:32:02 +0000 (GMT)
Subject: main - libdm: fix compiling with older gcc
Message-ID: <20210406203202.6FE1A384607A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6f6583afede02dddec41b85f896c9d4e73d87beb
Commit:        6f6583afede02dddec41b85f896c9d4e73d87beb
Parent:        9980ed9527e73d8396f8e1ce877837c0355ba8dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 6 22:31:23 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 22:31:23 2021 +0200

libdm: fix compiling with older gcc

---
 libdm/misc/dmlib.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/libdm/misc/dmlib.h b/libdm/misc/dmlib.h
index 95f4b8ecb..0b937cdda 100644
--- a/libdm/misc/dmlib.h
+++ b/libdm/misc/dmlib.h
@@ -77,7 +77,10 @@
 #  endif
 # endif
 #ifndef DM_EXPORT_NEW_SYMBOL
-#define DM_EXPORT_NEW_SYMBOL(rettype, func, ver) rettype func
+#define DM_EXPORT_NEW_SYMBOL(rettype, func, ver) \
+	__typeof__(func) func ##_v ##ver; \
+	__asm__(".symver " #func "_v" #ver ", " #func "@@DM_" #ver ); \
+	rettype func ##_v ##ver
 #define DM_EXPORT_SYMBOL(func, ver) \
 	__asm__(".symver " #func "_v" #ver ", " #func "@DM_" #ver );
 #define DM_EXPORT_SYMBOL_BASE(func) \


