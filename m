From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Feb 2017 21:34:08 +0000 (UTC)
Subject: master - args: in yes option mention qq for auto-no
Message-ID: <20170217213408.CB76C60E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3cf394389896a1bd6b3780671e6a6654a925bdd3
Commit:        3cf394389896a1bd6b3780671e6a6654a925bdd3
Parent:        f88ce5fb9954721b41fa1fc19c53abc18006c395
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 17 14:42:13 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 17 14:44:11 2017 -0600

args: in yes option mention qq for auto-no

---
 tools/args.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 06595a6..149b5f6 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1369,7 +1369,8 @@ arg(resizeable_ARG, 'x', "resizeable", bool_VAL, 0, 0,
 
 arg(yes_ARG, 'y', "yes", 0, 0, 0,
     "Do not prompt for confirmation interactively but always assume the\n"
-    "answer yes. Use with extreme caution.\n")
+    "answer yes. Use with extreme caution.\n"
+    "(For automatic no, see -qq.)\n")
 
 arg(zero_ARG, 'Z', "zero", bool_VAL, 0, 0,
     "#lvchange\n"


