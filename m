From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:52 +0000 (GMT)
Subject: main - hints: keep strings aligned in structure
Message-ID: <20210308144652.3BDCC3952537@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ca12dae32b03c54509608621b9268853b030fd40
Commit:        ca12dae32b03c54509608621b9268853b030fd40
Parent:        ff21723512cb633c741e516381899f70e0d9ef2a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 7 16:28:59 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:33:15 2021 +0100

hints: keep strings aligned in structure

Preffer aligned string access.
---
 lib/label/hints.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/label/hints.h b/lib/label/hints.h
index 51143343d..e8cfd6a7e 100644
--- a/lib/label/hints.h
+++ b/lib/label/hints.h
@@ -17,10 +17,10 @@
 
 struct hint {
 	struct dm_list list;
-	char name[PATH_MAX];
-	char pvid[ID_LEN + 1];
-	char vgname[NAME_LEN];
 	dev_t devt;
+	char name[PATH_MAX]   __attribute__((aligned(8)));
+	char vgname[NAME_LEN] __attribute__((aligned(8)));
+	char pvid[ID_LEN + 1] __attribute__((aligned(8)));
 	unsigned chosen:1; /* this hint's dev was chosen for scanning */
 };
 


