From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 6 May 2019 07:03:56 -0400
Subject: master - tests: split args
Message-ID: <201905061103.x46B3uwe010251@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f7c9da554fdb9069bc46e973678e055a491ea1d
Commit:        1f7c9da554fdb9069bc46e973678e055a491ea1d
Parent:        4ff472b9071e2a6efef96e425cbe38cc63280189
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 6 13:02:45 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 6 13:02:45 2019 +0200

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
 
 


