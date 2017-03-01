From: David Teigland <teigland@sourceware.org>
Date: Wed, 1 Mar 2017 18:00:45 -0500
Subject: master - man: fix typo
Message-ID: <201703012300.v21N0j1T029264@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c25b95e2ef01874e67048f96b1e4928ec12fdb4e
Commit:        c25b95e2ef01874e67048f96b1e4928ec12fdb4e
Parent:        51dfbf1fb34199d00fcace378df50f580f7ed57d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 1 16:59:17 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 1 16:59:51 2017 -0600

man: fix typo

---
 tools/args.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index f4eec0b..66de6d5 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -693,7 +693,7 @@ arg(unquoted_ARG, '\0', "unquoted", 0, 0, 0,
     "pairs are not quoted.\n")
 
 arg(usepolicies_ARG, '\0', "usepolicies", 0, 0, 0,
-    "Perform an operation according to the policy configured in lvm.conf.\n"
+    "Perform an operation according to the policy configured in lvm.conf\n"
     "or a profile.\n")
 
 arg(validate_ARG, '\0', "validate", 0, 0, 0,


