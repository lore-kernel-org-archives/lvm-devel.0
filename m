From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:34 +0000 (GMT)
Subject: main - cov: guard index
Message-ID: <20210727225034.34635385040A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b7edda8a98281b6eb400fe41f2498e031bce7ccf
Commit:        b7edda8a98281b6eb400fe41f2498e031bce7ccf
Parent:        d4994915015498bc0382fc6624d2f843f865ae51
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 15:53:48 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:28 2021 +0200

cov: guard index

Analyzer wants explicit protect to not underflow index.
---
 lib/activate/activate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 94fc9441d..b44efc617 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -563,7 +563,7 @@ int module_present(struct cmd_context *cmd, const char *target_name)
 			    dm_sysfs_dir(), target_name);
 
 	if (i > 0) {
-		while (path[--i] != '/')  /* stop on dm_ */
+		while ((i > 0) && path[--i] != '/')  /* stop on dm_ */
 			if (path[i] == '-')
 				path[i] = '_'; /* replace '-' with '_' */
 


