From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:06 +0000 (GMT)
Subject: main - args.h: bold command refference
Message-ID: <20210423210606.87B66394480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6f61de300980a55381c70347712c22a96c22807b
Commit:        6f61de300980a55381c70347712c22a96c22807b
Parent:        f678052385dd7fe04e4d4c3681b7dd58b1bca64b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 23 22:45:20 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

args.h: bold command refference

---
 tools/args.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/args.h b/tools/args.h
index 93ee737ce..741c82b9f 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1386,7 +1386,7 @@ arg(readahead_ARG, 'r', "readahead", readahead_VAL, 0, 0,
     "\\fBnone\\fP is equivalent to zero.\n")
 
 arg(resizefs_ARG, 'r', "resizefs", 0, 0, 0,
-    "Resize underlying filesystem together with the LV using fsadm(8).\n")
+    "Resize underlying filesystem together with the LV using \\fBfsadm\\fP(8).\n")
 
 /* Not used */
 arg(reset_ARG, 'R', "reset", 0, 0, 0, NULL)


