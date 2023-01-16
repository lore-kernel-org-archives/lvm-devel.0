From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 16 Jan 2023 11:39:19 +0000 (GMT)
Subject: main - makefiles: comment out hiding dir entering
Message-ID: <20230116113919.B8B323858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a58e08b8c1ef8b988a588301e097f50c843f0aa
Commit:        3a58e08b8c1ef8b988a588301e097f50c843f0aa
Parent:        3bedceec3882e00caf62df6fbeb946aeafea9df2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 12 16:52:01 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 16 12:37:40 2023 +0100

makefiles: comment out hiding dir entering

While the output of building looks more polished, text editors fail to
find source file from compile errors - so until we start to print
all file with full paths - comment out this make build parameter.
---
 make.tmpl.in | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index e942893a0..222ed671a 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -182,9 +182,10 @@ ifndef MAKEFLAGS
 MAKEFLAGS = @JOBS@
 endif
 
-ifneq (1, $(firstword $(V)))
-MAKEFLAGS += --no-print-directory
-endif
+# Hiding dir entering makes hard for editors to look for files
+#ifneq (1, $(firstword $(V)))
+#MAKEFLAGS += --no-print-directory
+#endif
 
 # Handle installation of files
 ifeq ("@WRITE_INSTALL@", "yes")

