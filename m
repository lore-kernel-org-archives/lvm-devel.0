From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Nov 2019 12:21:57 -0500
Subject: master - writecache: modprobe dm-writecache
Message-ID: <49945.119112612215000135@us-mta-13.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c9b36618ec8357350ed4d83c807ae0bf27a12be
Commit:        1c9b36618ec8357350ed4d83c807ae0bf27a12be
Parent:        bbd8badaef630c3534ccd1ae27602b66c37d5c6e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 26 11:21:09 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 26 11:21:09 2019 -0600

writecache: modprobe dm-writecache

---
 lib/writecache/writecache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index 0a5b485..130922a 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -214,7 +214,7 @@ static int _target_present(struct cmd_context *cmd,
 
 	if (!_writecache_checked) {
 		_writecache_checked = 1;
-		_writecache_present =  target_present(cmd, TARGET_NAME_WRITECACHE, 0);
+		_writecache_present =  target_present(cmd, TARGET_NAME_WRITECACHE, 1);
 	}
 
 	return _writecache_present;



