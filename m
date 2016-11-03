From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 11:43:25 +0000 (UTC)
Subject: master - cleanup: add 'static' for local struct
Message-ID: <20161103114325.F3B4F60DB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28b210f4fa10ef5e9baf4e28a891460eb65eb602
Commit:        28b210f4fa10ef5e9baf4e28a891460eb65eb602
Parent:        1db4b81d5a1e7c85ab5928c9f6a62ec9565885df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 2 14:26:41 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 12:43:09 2016 +0100

cleanup: add 'static' for local struct

---
 lib/log/log.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 2207c7e..f9d5649 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -67,7 +67,7 @@ struct log_stream_item {
 	char *buffer;
 };
 
-struct log_stream {
+static struct log_stream {
 	struct log_stream_item out;
 	struct log_stream_item err;
 	struct log_stream_item report;


