From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:56 +0000 (GMT)
Subject: stable-2.02 - dmsetup: initilize winsize struct
Message-ID: <20201016191056.3AC9A396EC5D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1ac22fb00b5e95645eabd886967cbcaf4768ff09
Commit:        1ac22fb00b5e95645eabd886967cbcaf4768ff09
Parent:        6b97921ee849914e1476d718208ac449cf3c982e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 20:35:49 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:06 2020 +0200

dmsetup: initilize winsize struct

Ensure winsize struct is always defined.
---
 tools/dmsetup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8837826e9..d158b7991 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -6491,7 +6491,7 @@ static int _stats(CMD_ARGS)
 static int _process_tree_options(const char *options)
 {
 	const char *s, *end;
-	struct winsize winsz;
+	struct winsize winsz = { 0 };
 	size_t len;
 
 	/* Symbol set default */


