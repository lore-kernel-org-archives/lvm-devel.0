From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Apr 2017 15:16:13 -0400
Subject: master - lvchange: refresh command missing activationmode option
Message-ID: <201704031916.v33JGD3P015845@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e0f284d3728d3381966dd290e205951ed99e54f9
Commit:        e0f284d3728d3381966dd290e205951ed99e54f9
Parent:        25b5915c9b5260c59d627bd1f6db8220bd4ad61e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 3 13:44:35 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 3 13:44:35 2017 -0500

lvchange: refresh command missing activationmode option

---
 tools/command-lines.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 6a345f3..9f0fc79 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -281,7 +281,7 @@ ID: lvchange_activate
 DESC: Activate or deactivate an LV.
 
 lvchange --refresh VG|LV|Tag|Select ...
-OO: --partial, --poll Bool, OO_LVCHANGE
+OO: --activationmode ActivationMode, --partial, --poll Bool, OO_LVCHANGE
 ID: lvchange_refresh
 DESC: Reactivate an LV using the latest metadata.
 


