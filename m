From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Sep 2020 21:30:44 +0000 (GMT)
Subject: master - tests: bigger data still needed for 0.7.0
Message-ID: <20200917213044.1CCD1393C86C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a5e867139d31b42e3bd084ecd0aefe1eabfa380c
Commit:        a5e867139d31b42e3bd084ecd0aefe1eabfa380c
Parent:        7f019f2580eadbb7893388e0be0e095753f4a9d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 17 23:26:03 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 17 23:27:52 2020 +0200

tests: bigger data still needed for 0.7.0

---
 test/shell/lvextend-thin-metadata-dmeventd.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 3a837326c..5f6db994a 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -63,7 +63,7 @@ aux have_thin 1 10 0 || skip
 BIG_DATA=""
 case $("$LVM_TEST_THIN_RESTORE_CMD" -V) in
 	# With older version of thin-tool we got slightly more compact metadata
-	0.[0-6]*) BIG_DATA="generate_more_metadata" ;;
+	0.[0-6]*|0.7.0*) BIG_DATA="generate_more_metadata" ;;
 esac
 
 aux prepare_dmeventd


