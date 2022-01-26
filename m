From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 26 Jan 2022 14:10:31 +0000 (GMT)
Subject: main - lvcreate: cachesettings works also with writecache
Message-ID: <20220126141031.5967938515DC@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d8dbabb28e674e9f2aac2716b235f27f1d333e1a
Commit:        d8dbabb28e674e9f2aac2716b235f27f1d333e1a
Parent:        a06ccdf44bd385863792baed887303c714da9685
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 18 19:06:21 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 26 15:09:58 2022 +0100

lvcreate: cachesettings works also with writecache

---
 tools/lvcreate.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 0115b3c32..2c519d555 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -823,6 +823,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	alloc_ARG,\
 	autobackup_ARG,\
 	available_ARG,\
+	cachesettings_ARG,\
 	contiguous_ARG,\
 	devices_ARG,\
 	devicesfile_ARG,\
@@ -846,8 +847,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	cachemetadataformat_ARG,\
 	cachemode_ARG,\
 	cachepool_ARG,\
-	cachepolicy_ARG,\
-	cachesettings_ARG
+	cachepolicy_ARG
 
 #define MIRROR_ARGS \
 	corelog_ARG,\


