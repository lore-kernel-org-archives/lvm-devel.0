From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:54 +0000 (GMT)
Subject: main - lvmdbusd: Remove unneeded command line args
Message-ID: <20220919155754.778263858C00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c13efb2ffc90853884e77f0d2b28e8d1936c74d0
Commit:        c13efb2ffc90853884e77f0d2b28e8d1936c74d0
Parent:        b3d8366ff21ee69380ab5fbca48204212a64a0cd
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 9 17:45:04 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbusd: Remove unneeded command line args

---
 daemons/lvmdbusd/cmdhandler.py | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 0c4d5cb61..7b3ad528b 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -234,8 +234,7 @@ call = time_wrapper
 # Default cmd
 # Place default arguments for every command here.
 def _dc(cmd, args):
-	c = [cmd, '--noheading', '--separator', '%s' % SEP, '--nosuffix',
-		'--unbuffered', '--units', 'b']
+	c = [cmd, '--nosuffix', '--unbuffered', '--units', 'b']
 	c.extend(args)
 	return c
 

