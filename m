From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:09 +0000 (GMT)
Subject: stable-2.02 - debug: no backtrace
Message-ID: <20201016191209.40CB0396EC88@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c68380746ab82a5c2517c71435daf830fa158a6f
Commit:        c68380746ab82a5c2517c71435daf830fa158a6f
Parent:        b97440290c952c33e32f86f7d4b0e47ed6e30d4d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 11:14:18 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

debug: no backtrace

As the path already printed verbose message drop backtrace.
---
 lib/label/label.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 7cebbdcf9..019fd09ca 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -412,7 +412,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 		lvmcache_del_dev(dev); /* FIXME: if this is needed, fix it. */
 
 		*is_lvm_device = 0;
-		goto_out;
+		goto out;
 	}
 
 	*is_lvm_device = 1;


