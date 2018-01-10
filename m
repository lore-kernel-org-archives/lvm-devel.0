From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 10:53:22 -0500
Subject: master - allocation: Avoid exceeding array bounds in allocation tag code
Message-ID: <201801101553.w0AFrMOU004702@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bacc94233368cf136b55e2574e969e7f53b31c6c
Commit:        bacc94233368cf136b55e2574e969e7f53b31c6c
Parent:        e2438b5b9ff526cae8fa29ca7023b43995f00647
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 10 02:03:32 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 10 15:48:03 2018 +0000

allocation: Avoid exceeding array bounds in allocation tag code

If _limit_to_one_area_per_tag() changes nothing it writes beyond
the array.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 345c472..897576c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Avoid exceeding array bounds in allocation tag processing.
   Refactor metadata reading code to use callback functions.
   Move memory allocation for the key dev_reads into the device layer.
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 70dc2d9..ac30dad 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2737,7 +2737,8 @@ static int _limit_to_one_area_per_tag(struct alloc_handle *ah, struct alloc_stat
 		s++;
 	}
 
-	alloc_state->areas[u].pva = NULL;
+	if (u < alloc_state->areas_size)
+		alloc_state->areas[u].pva = NULL;
 
 	return 1;
 }


