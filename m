From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Nov 2015 18:01:48 +0000 (UTC)
Subject: master - coverity: trying different model
Message-ID: <20151117180148.8F62460B64@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6167f5da103fe3d3619cfee1166a66b058e5b3ba
Commit:        6167f5da103fe3d3619cfee1166a66b058e5b3ba
Parent:        83661c8f7f954816284baf385fedfea4c4d57a88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 17 18:58:15 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 17 19:01:25 2015 +0100

coverity: trying different model

Model reseting of given set, but it still makes
FD_SET to think it's accessing uninitialized value.

Maybe model also FD_SET.
---
 coverity/coverity_model.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/coverity/coverity_model.c b/coverity/coverity_model.c
index d41c67c..dfd6158 100644
--- a/coverity/coverity_model.c
+++ b/coverity/coverity_model.c
@@ -66,8 +66,9 @@ void *memccpy(void *dest, const void *src, int c, size_t n)
 void model_FD_ZERO(void *fdset)
 {
 	unsigned i;
-	for (i = 0; i < 1024 / 8 / sizeof(int); ++i)
-		((int*)fdset)[i];
+
+	for (i = 0; i < 1024 / 8 / sizeof(long); ++i)
+		((long*)fdset)[i] = 0;
 }
 
 /*


