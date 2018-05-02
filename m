From: David Teigland <teigland@sourceware.org>
Date: Wed, 2 May 2018 15:11:20 -0400
Subject: master - filters: increase MAX_FILTERS for new filter
Message-ID: <201805021911.w42JBKAd011309@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=977d0a361301d9383a25291fe8cfdd6cea93e22d
Commit:        977d0a361301d9383a25291fe8cfdd6cea93e22d
Parent:        90d0ff66362f3f21f79b5204bcc072c12185883b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 2 14:10:30 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 2 14:10:30 2018 -0500

filters: increase MAX_FILTERS for new filter

The new signature filter was added without increasing this.
---
 lib/commands/toolcontext.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 7f74c7e..76e15e0 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1053,7 +1053,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	return 1;
 }
 
-#define MAX_FILTERS 9
+#define MAX_FILTERS 10
 
 static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 {


