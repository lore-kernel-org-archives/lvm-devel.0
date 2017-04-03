From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Apr 2017 17:21:55 -0400
Subject: master - commands: missing comma in cmd def option list
Message-ID: <201704032121.v33LLt1b031354@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=29161a145e9c1c50157dca30c17957e4699826d6
Commit:        29161a145e9c1c50157dca30c17957e4699826d6
Parent:        db579b9e936df14edb9c06830c21e5b5aef666a4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 3 16:20:55 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 3 16:20:55 2017 -0500

commands: missing comma in cmd def option list

Does not affect parsing, but keep it consistent.
---
 tools/command-lines.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index a83fb43..b2682fa 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -297,7 +297,7 @@ ID: lvchange_poll
 DESC: Start or stop processing an LV conversion.
 
 lvchange --persistent y --minor Number LV
-OO: --major Number, --activate Activate OO_LVCHANGE
+OO: --major Number, --activate Activate, OO_LVCHANGE
 ID: lvchange_persistent
 DESC: Make the minor device number persistent for an LV.
 RULE: all not LV_thinpool LV_cachepool


