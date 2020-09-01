From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:01:59 +0000 (GMT)
Subject: master - dmsetup: initilize winsize struct
Message-ID: <20200901170159.9FE9D38708C5@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f377a04e5563166e4b865e92bc36d088107561a
Commit:        0f377a04e5563166e4b865e92bc36d088107561a
Parent:        2fbc578cfa0bde161b7583978537d2023e5d6e0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 20:35:49 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

dmsetup: initilize winsize struct

Ensure winsize struct is always defined.
---
 libdm/dm-tools/dmsetup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index bf2762ae7..46fa81069 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -6494,7 +6494,7 @@ static int _stats(CMD_ARGS)
 static int _process_tree_options(const char *options)
 {
 	const char *s, *end;
-	struct winsize winsz;
+	struct winsize winsz = { 0 };
 	size_t len;
 
 	/* Symbol set default */


