From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:48:46 +0000 (GMT)
Subject: dev-next - make: add few more predef symbols for cflow
Message-ID: <20210331214846.EED473857C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f370cda716f14d0ba1ba97fa3dd5887d5165b140
Commit:        f370cda716f14d0ba1ba97fa3dd5887d5165b140
Parent:        0993355300fa8490163579a320d1b289c7db59af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 20 19:02:41 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:51:24 2021 +0100

make: add few more predef symbols for cflow

---
 make.tmpl.in | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index d95d956fa..99998f9fd 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -404,7 +404,10 @@ ifneq ("$(CFLOW_CMD)", "")
 CFLOW_FLAGS +=\
  --cpp="$(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(BLKID_CFLAGS) $(DEFS)" \
  --symbol _ISbit:wrapper \
+ --symbol __asm__:wrapper \
  --symbol __attribute__:wrapper \
+ --symbol __inline:=inline \
+ --symbol __inline__:=inline \
  --symbol __const:type \
  --symbol __const__:wrapper \
  --symbol __extension__:wrapper \
@@ -414,7 +417,7 @@ CFLOW_FLAGS +=\
  --symbol __pure__:wrapper \
  --symbol __REDIRECT:wrapper \
  --symbol __REDIRECT_NTH:wrapper \
- --symbol __restrict:type \
+ --symbol __restrict:=restrict \
  --symbol __wur:wrapper
 
 $(CFLOW_TARGET).cflow: $(CFLOW_SOURCES)


