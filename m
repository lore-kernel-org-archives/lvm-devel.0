From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:48 +0000 (GMT)
Subject: main - cov: avoid passed invalid dummy structure
Message-ID: <20210423210548.3E95C39450F4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ece80cd0fbce92d2ce248913fceffbf15e9d37f0
Commit:        ece80cd0fbce92d2ce248913fceffbf15e9d37f0
Parent:        bf461b99c6d26e550835b77eaffe2204cbc9bed3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 12:32:35 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: avoid passed invalid dummy structure

Altough this dummy structure should not be using pe_size anywhere,
make analyzer happier and avoid PV structures with zero pe_size.
---
 tools/toollib.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/toollib.c b/tools/toollib.c
index 5ce2ff346..8f9ea1e6b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4000,6 +4000,7 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 	int ret = 0;
 
 	struct physical_volume dummy_pv = {
+		.pe_size = 1,
 		.tags = DM_LIST_HEAD_INIT(dummy_pv.tags),
 		.segments= DM_LIST_HEAD_INIT(dummy_pv.segments),
 	};


