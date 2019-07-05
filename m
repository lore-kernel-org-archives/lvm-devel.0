From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 5 Jul 2019 19:26:35 -0400
Subject: stable-2.02 - tests: split args
Message-ID: <201907052326.x65NQZ1Y009767@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=143aca25daa2303a9494bace28262e64bd77698d
Commit:        143aca25daa2303a9494bace28262e64bd77698d
Parent:        1e9c409a3eef3c18f97b70a3d679ea24a2458886
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 6 13:02:45 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jul 6 01:24:28 2019 +0200

tests: split args

Here we want args to be splited into individual strings.
---
 test/shell/fsadm-crypt.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 9c85edf..68fed95 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -137,7 +137,7 @@ get_crypt_kname() {
 # $1 device
 # $2 pass
 crypt_format() {
-	echo "$2" | cryptsetup luksFormat "$FORMAT_PARAMS" "$1"
+	echo "$2" | cryptsetup luksFormat $FORMAT_PARAMS "$1"
 }
 
 


