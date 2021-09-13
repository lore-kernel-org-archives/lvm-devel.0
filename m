From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:09 +0000 (GMT)
Subject: main - cov: fix copy from tmp_name buffer
Message-ID: <20210913103609.3BECE3858006@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa522d586227ecafb18d671cab284ae27ca65eed
Commit:        aa522d586227ecafb18d671cab284ae27ca65eed
Parent:        7af0a1b9d87827f0d15e6b062b753ee3043f75dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 9 22:32:09 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cov: fix copy from tmp_name buffer

Mask for strncpy() Coverity report warning would
actually need to copy buffer from 'tmp_name' instead of 'str'.

But replace it directly with single 'strncpy()' again for better readbility,
just mask out the warning reported for this strncpy instance
(so we do not need to put comment fro every call of strcpy_name_len).
---
 daemons/lvmlockd/lvmlockd-sanlock.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index b351b1d44..13567cf95 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -234,11 +234,8 @@ static uint64_t daemon_test_lv_count;
  */
 static void strcpy_name_len(char *buf, char *str, int len)
 {
-	char tmp_name[SANLK_NAME_LEN + 1] = { 0 };
-
-	strncpy(tmp_name, str, SANLK_NAME_LEN);
-
-	memcpy(buf, str, SANLK_NAME_LEN);
+	/* coverity[buffer_size_warning] */
+	strncpy(buf, str, SANLK_NAME_LEN);
 }
 
 static int lock_lv_name_from_args(char *vg_args, char *lock_lv_name)


