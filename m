From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:28:07 +0000 (GMT)
Subject: master - rpm: bare words are no longer supported
Message-ID: <20201002202807.160D639494B4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ee43ec5782c3fe23b99e84da86fa3f43d3eb1c56
Commit:        ee43ec5782c3fe23b99e84da86fa3f43d3eb1c56
Parent:        99b6173f10fe7e2dbd54bb8734667ca8df69905e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 22:13:51 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 22:27:00 2020 +0200

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


