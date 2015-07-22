From: okozina <okozina@fedoraproject.org>
Date: Wed, 22 Jul 2015 11:02:47 +0000 (UTC)
Subject: master - lvconvert: remove unused struct members
Message-ID: <20150722110247.6A68C6106F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00d24511bc5e1ae446867f65b5adfe3e7d404398
Commit:        00d24511bc5e1ae446867f65b5adfe3e7d404398
Parent:        03762f42c18812b95c550fefcdf531e0ff2f78b0
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Jul 22 12:56:43 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Jul 22 12:56:43 2015 +0200

lvconvert: remove unused struct members

---
 tools/lvconvert.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d979e84..0c5e2bd 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -40,9 +40,6 @@ struct lvconvert_params {
 	int wait_completion;
 	int need_polling;
 
-	int is_merging_origin;
-	int is_merging_origin_thin;
-
 	int thin_chunk_size_calc_policy;
 	uint32_t chunk_size;
 	uint32_t region_size;


