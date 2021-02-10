From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Feb 2021 14:44:00 +0000 (GMT)
Subject: main - gcc: ensure pointer is always defined
Message-ID: <20210210144400.7AE683857C7B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1e2541333ed551c41882e2a636a1ab981d425b9
Commit:        a1e2541333ed551c41882e2a636a1ab981d425b9
Parent:        82bffa99ada0173704739b6fff856a3d6cb5455d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 10 14:30:58 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 10 15:39:03 2021 +0100

gcc: ensure pointer is always defined

---
 daemons/lvmlockd/lvmlockd-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index c4abf66be..b271a9aee 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -872,7 +872,7 @@ static int read_adopt_file(struct list_head *vg_lockd)
 	char vg_uuid[72];
 	char lm_type_str[16];
 	char mode[8];
-	struct lockspace *ls, *ls2;
+	struct lockspace *ls = NULL, *ls2;
 	struct resource *r;
 	FILE *fp;
 


