From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:31 +0000 (GMT)
Subject: main - makefiles: remove unneeded var changes
Message-ID: <20210406200731.E59123846079@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e86cd9c5ba5f675798d2553359632b44d2fe237f
Commit:        e86cd9c5ba5f675798d2553359632b44d2fe237f
Parent:        9452e62efb28acdadc916c00d39e7cd615d5c953
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 4 13:13:38 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 22:02:31 2021 +0200

makefiles: remove unneeded var changes

---
 libdm/make.tmpl.in | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 219eeca9d..9ef39fc0a 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -250,9 +250,6 @@ endif
 # end of fPIC protection
 endif
 
-LDFLAGS += -L$(top_builddir)/libdm
-CLDFLAGS += -L$(top_builddir)/libdm
-
 # Combination of DEBUG_POOL and DEBUG_ENFORCE_POOL_LOCKING is not suppored.
 #DEFS += -DDEBUG_POOL
 # Default pool locking is using the crc checksum. With mprotect memory


