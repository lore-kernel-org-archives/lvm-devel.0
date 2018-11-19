From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Nov 2018 07:42:55 -0500
Subject: master - tests: generate slightly less volumes
Message-ID: <201811191242.wAJCgtTw016808@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b2261b5d81732d8d8c3445e9b8c4ce935bcc49d4
Commit:        b2261b5d81732d8d8c3445e9b8c4ce935bcc49d4
Parent:        54de0d829b0e07ee48e92d68b428dfed8d6d7bf1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 19 13:39:39 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 13:42:23 2018 +0100

tests: generate slightly less volumes

---
 test/shell/metadata-full.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/metadata-full.sh b/test/shell/metadata-full.sh
index eb617ee..67333d8 100644
--- a/test/shell/metadata-full.sh
+++ b/test/shell/metadata-full.sh
@@ -42,7 +42,7 @@ vgcreate $SHARED -s 512K --metadatacopies 8 $vg "${DEVICES[@]}"
 # is written.
 
 vgcfgbackup -f data $vg
-TEST_DEVS=930
+TEST_DEVS=925
 # Generate a lot of LV devices (size of 1 extent)
 awk -v TEST_DEVS=$TEST_DEVS '/^\t\}/ {
     printf("\t}\n\tlogical_volumes {\n");


