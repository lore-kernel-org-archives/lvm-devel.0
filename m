From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 29 Aug 2014 11:12:32 +0000 (UTC)
Subject: master - clvmd: use correctly sized buffers for sscanf
Message-ID: <20140829111232.D55EE60FE8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c8fa2aa01dd6639b146e537ddcc2709752678d2
Commit:        3c8fa2aa01dd6639b146e537ddcc2709752678d2
Parent:        91a453de0506a68b374e4e4b36f904eb5bb5a46f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 29 12:00:05 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 29 13:10:20 2014 +0200

clvmd: use correctly sized buffers for sscanf

sscanf needs extra 1 char for '\0'
---
 daemons/clvmd/lvm-functions.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 1754b7d..f3a56ce 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -725,7 +725,7 @@ void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
 static int get_initial_state(struct dm_hash_table *excl_uuid)
 {
 	int lock_mode;
-	char lv[64], vg[64], flags[25], vg_flags[25];
+	char lv[65], vg[65], flags[26], vg_flags[26]; /* with space for '\0' */
 	char uuid[65];
 	char line[255];
 	char *lvs_cmd;


