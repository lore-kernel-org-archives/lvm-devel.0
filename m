From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:56 +0000 (GMT)
Subject: main - cleanup: reuse existing code for free path
Message-ID: <20210927165756.A5A63385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8a958cc04da2c23e2a7a168ae19f05d4fcab1ae
Commit:        a8a958cc04da2c23e2a7a168ae19f05d4fcab1ae
Parent:        9668427fe8d08f2c0e3f778c53bc00181478f71c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 27 11:42:45 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

cleanup: reuse existing code for free path

---
 lib/format_text/format-text.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index b2bbf3c66..e8b1865f8 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -964,12 +964,8 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	r = 1;
 
       out:
-	if (!r) {
-		free(fidtc->write_buf);
-		fidtc->write_buf = NULL;
-		fidtc->write_buf_size = 0;
-		fidtc->new_metadata_size = 0;
-	}
+	if (!r)
+		free_text_fidtc(vg);
 
 	return r;
 }
@@ -1154,12 +1150,8 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	r = 1;
 
       out:
-	if (!precommit && !fidtc->preserve) {
-		free(fidtc->write_buf);
-		fidtc->write_buf = NULL;
-		fidtc->write_buf_size = 0;
-		fidtc->new_metadata_size = 0;
-	}
+	if (!precommit && !fidtc->preserve)
+		free_text_fidtc(vg);
 
 	return r;
 }


