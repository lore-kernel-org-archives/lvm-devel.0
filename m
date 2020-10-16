From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:22 +0000 (GMT)
Subject: stable-2.02 - rpm: bare words are no longer supported
Message-ID: <20201016191222.EF817396EC92@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c262bfc85f62c94421ab2d687c74585c3e27d3f
Commit:        7c262bfc85f62c94421ab2d687c74585c3e27d3f
Parent:        7d3e7266c76591be4b99487c2b1ea61ce525c074
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 22:13:51 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

rpm: bare words are no longer supported

Update for new rpm requirement and use "..." words.
---
 spec/macros.inc | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/spec/macros.inc b/spec/macros.inc
index 99ee9a06a..d4e99e6ae 100644
--- a/spec/macros.inc
+++ b/spec/macros.inc
@@ -58,11 +58,11 @@ fi \
 %%if %%{enable_systemd} \
 if [ $1 = 0 ]; then \
 	systemctl --no-reload disable lvm2-%%{-s*}.%%{-t*} > /dev/null 2>&1 || : \
-	%%if %%{-t*} == socket \
+	%%if "%%{-t*}" == "socket" \
 	systemctl --no-reload disable lvm2-%%{-s*}.service > /dev/null 2>&1 || : \
 	%%endif \
 	systemctl stop lvm2-%%{-s*}.%%{-t*} > /dev/null 2>&1 || : \
-	%%if %%{-t*} == socket \
+	%%if "%%{-t*}" == "socket" \
 	systemctl stop lvm2-%%{-s*}.service > /dev/null 2>&1 || : \
 	%%endif \
 fi \


