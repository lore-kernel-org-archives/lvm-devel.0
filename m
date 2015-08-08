From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sat,  8 Aug 2015 10:49:40 +0000 (UTC)
Subject: master - libdm: ensure new dm_timestamp objects are initialized
Message-ID: <20150808104940.91352601D5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=974e7b9220f26154c5f491ca8ec49f57dd834c66
Commit:        974e7b9220f26154c5f491ca8ec49f57dd834c66
Parent:        b59cdf089217e1b86b2106bdccb990bda92690e5
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 7 13:10:34 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Aug 8 10:42:14 2015 +0100

libdm: ensure new dm_timestamp objects are initialized

Allocate a dm_timestamp with dm_zalloc() to ensure the memory is
initialized to a known state.
---
 libdm/libdm-timestamp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-timestamp.c b/libdm/libdm-timestamp.c
index 7690ccb..fe006d5 100644
--- a/libdm/libdm-timestamp.c
+++ b/libdm/libdm-timestamp.c
@@ -54,7 +54,7 @@ struct dm_timestamp *dm_timestamp_alloc(void)
 {
 	struct dm_timestamp *ts = NULL;
 
-	if (!(ts = dm_malloc(sizeof(*ts))))
+	if (!(ts = dm_zalloc(sizeof(*ts))))
 		stack;
 
 	return ts;


