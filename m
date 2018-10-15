From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:26 -0400
Subject: master - cov: fix failing filter initialization
Message-ID: <201810151555.w9FFtQ6E020607@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=13c49033ede4bb57878361e5ae04c96d4930e9fa
Commit:        13c49033ede4bb57878361e5ae04c96d4930e9fa
Parent:        a7298810d1fd0f64be3fd903e9f9fcce9af7b84c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 15:17:07 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: fix failing filter initialization

When persistent_filter_create() fails, the existing passed filter
should be preserved, so it could be properly deleted on
error path - so new pfilter is assigned instead.
---
 lib/commands/toolcontext.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index fa87bcc..9f00593 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1167,7 +1167,7 @@ bad:
  */
 int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 {
-	struct dev_filter *filter = NULL, *filter_components[2] = {0};
+	struct dev_filter *pfilter, *filter = NULL, *filter_components[2] = {0};
 
 	if (!cmd->initialized.connections) {
 		log_error(INTERNAL_ERROR "connections must be initialized before filters");
@@ -1192,12 +1192,12 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 	filter = cmd->lvmetad_filter;
 	cmd->lvmetad_filter = NULL;
 
-	if (!(filter = persistent_filter_create(cmd->dev_types, filter))) {
+	if (!(pfilter = persistent_filter_create(cmd->dev_types, filter))) {
 		log_verbose("Failed to create persistent device filter.");
 		goto bad;
 	}
 
-	cmd->filter = filter;
+	cmd->filter = filter = pfilter;
 
 	cmd->full_filter = filter;
 


