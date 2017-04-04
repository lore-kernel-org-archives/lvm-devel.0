From: David Teigland <teigland@sourceware.org>
Date: Tue, 4 Apr 2017 18:11:09 -0400
Subject: master - commands: fix misspelling of option value
Message-ID: <201704042211.v34MB9kM019244@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=afa844817a716f054f1e56612fa19522225797f4
Commit:        afa844817a716f054f1e56612fa19522225797f4
Parent:        a7d4156a9aba1454249c945d07ebbfc366d86eaf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 4 17:09:35 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 4 17:09:35 2017 -0500

commands: fix misspelling of option value

(The cmd def parser really needs to catch mistakes
like this as it did when it was external.)
---
 tools/command-lines.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 20a9e79..5a3b520 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -297,7 +297,7 @@ ID: lvchange_poll
 DESC: Start or stop processing an LV conversion.
 
 lvchange --persistent y --minor Number LV
-OO: --major Number, --activate Activate, --poll Bool, --monitor Bool, OO_LVCHANGE
+OO: --major Number, --activate Active, --poll Bool, --monitor Bool, OO_LVCHANGE
 ID: lvchange_persistent
 DESC: Make the minor device number persistent for an LV.
 RULE: all not LV_thinpool LV_cachepool


