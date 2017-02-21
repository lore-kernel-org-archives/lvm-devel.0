From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 21 Feb 2017 18:28:10 +0000 (UTC)
Subject: master - man: expand type option description
Message-ID: <20170221182810.56A366103B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f80d37375354b9b9cab5326d9d03e036012a824e
Commit:        f80d37375354b9b9cab5326d9d03e036012a824e
Parent:        d2dbe71fb3e6210b252db94ec214cee6df2ddb4f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 21 11:09:01 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 21 12:27:51 2017 -0600

man: expand type option description

---
 tools/args.h |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index e7a1ab2..036aa87 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -646,7 +646,16 @@ arg(trustcache_ARG, '\0', "trustcache", 0, 0, 0,
     "Avoids certain device scanning during command processing. Do not use.\n")
 
 arg(type_ARG, '\0', "type", segtype_VAL, 0, 0,
-    "Specifies an LV type, or \"segment type\".\n")
+    "Specifies an LV type, or \"segment type\".\n"
+    "See usage definitions for specific ways to use these types.\n"
+    "For more information about redundancy and performance (\\fBraid\\fP<N>, \\fBmirror\\fP, \\fBstriped\\fP, \\fBlinear\\fP) see \\fBlvmraid\\fP(7).\n"
+    "For thin provisioning (\\fBthin\\fP, \\fBthin-pool\\fP) see \\fBlvmthin\\fP(7).\n"
+    "For performance caching (\\fBcache\\fP, \\fBcache-pool\\fP) see \\fBlvmcache\\fP(7).\n"
+    "For copy-on-write snapshots (\\fBsnapshot\\fP) see usage definitions.\n"
+    "Several commands omit an explicit type option because the type\n"
+    "is inferred from other options or shortcuts\n"
+    "(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).\n"
+    "Use inferred types with care because it can lead to unexpected results.\n")
 
 arg(unbuffered_ARG, '\0', "unbuffered", 0, 0, 0,
     "Produce output immediately without sorting or aligning the columns properly.\n")


