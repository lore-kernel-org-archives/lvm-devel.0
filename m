From: mcsontos@redhat.com <mcsontos@redhat.com>
Date: Thu, 14 Dec 2017 16:57:58 +0100
Subject: [PATCH] make: Fix typo in M_INSTALL_SCRIPT
Message-ID: <1513267078-9452-1-git-send-email-mcsontos@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Marian Csontos <mcsontos@redhat.com>

- M_INSTALL_SCRIPT is unused, should be M_INSTALL_PROGRAM
---
 make.tmpl.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index bdf2349..98bd217 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -147,7 +147,7 @@ endif
 # Handle installation of files
 ifeq ("@WRITE_INSTALL@", "yes")
 # leaving defaults
-M_INSTALL_SCRIPT =
+M_INSTALL_PROGRAM =
 M_INSTALL_DATA = -m 644
 else
 M_INSTALL_PROGRAM = -m 555
-- 
1.8.3.1


