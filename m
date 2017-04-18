From: David Teigland <teigland@sourceware.org>
Date: Tue, 18 Apr 2017 16:57:05 -0400
Subject: master - man: quote the word no
Message-ID: <201704182057.v3IKv5Vc024471@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b9d10857b26533dcd52c4d482af0a9291670858e
Commit:        b9d10857b26533dcd52c4d482af0a9291670858e
Parent:        658d524d26f2cff9bde31142ecab6d17fd2c54dd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 18 15:55:57 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 18 15:56:48 2017 -0500

man: quote the word no

---
 tools/args.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 24e3918..be1711b 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1234,7 +1234,7 @@ arg(physicalvolume_ARG, 'P', "physicalvolume", 0, 0, 0, NULL)
 
 arg(quiet_ARG, 'q', "quiet", 0, ARG_COUNTABLE, 0,
     "Suppress output and log messages. Overrides --debug and --verbose.\n"
-    "Repeat once to also suppress any prompts with answer no.\n")
+    "Repeat once to also suppress any prompts with answer 'no'.\n")
 
 arg(readahead_ARG, 'r', "readahead", readahead_VAL, 0, 0,
     "Sets read ahead sector count of an LV.\n"


