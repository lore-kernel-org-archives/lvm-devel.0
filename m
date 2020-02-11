From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Feb 2020 14:01:36 -0500
Subject: master - writecache: check if cachevol is writable
Message-ID: <68811.120021114013100899@us-mta-379.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cba06012acc589888ef88221f1a580b5b81b4100
Commit:        cba06012acc589888ef88221f1a580b5b81b4100
Parent:        892a182975049ebe732860c30c866fe2de5b7717
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 11 12:59:39 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 11 13:01:13 2020 -0600

writecache: check if cachevol is writable

before trying to initialize it (since wipe_lv
does not return an error if it fails to write.)
---
 tools/lvconvert.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index cd9a3e8..aa2dca7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5351,6 +5351,11 @@ static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
 	};
 	int ret;
 
+	if (!(lv->status & LVM_WRITE)) {
+		log_error("Cannot initialize readonly LV %s", display_lvname(lv));
+		return 0;
+	}
+
 	if (test_mode())
 		return 1;
 



