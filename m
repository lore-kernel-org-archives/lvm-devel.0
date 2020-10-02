From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:28:01 +0000 (GMT)
Subject: master - debug: no backtrace
Message-ID: <20201002202801.52E4F39494B4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=117fc64e6ef0905e6474d2bf67a890e97d6da450
Commit:        117fc64e6ef0905e6474d2bf67a890e97d6da450
Parent:        1b8c6f09bcba1996892a231bc6c25be6ac40d808
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 11:14:18 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 21:04:16 2020 +0200

debug: no backtrace

As the path already printed verbose message drop backtrace.
---
 lib/label/label.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index de01e4532..ec774dc6e 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -417,7 +417,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 		lvmcache_del_dev(dev); /* FIXME: if this is needed, fix it. */
 
 		*is_lvm_device = 0;
-		goto_out;
+		goto out;
 	}
 
 	dev->flags |= DEV_SCAN_FOUND_LABEL;


