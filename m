From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:16 +0000 (GMT)
Subject: master - tools: move struct element before variable lenght list
Message-ID: <20200828195916.7A3733948A51@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b918afb693a62938e8189a5d07b13df8007ae062
Commit:        b918afb693a62938e8189a5d07b13df8007ae062
Parent:        7880896f0dbe730e7b47aa8040544434813eacc4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 19:15:42 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:02 2020 +0200

tools: move struct element before variable lenght list

Move prio field before 'variable' struct array field.
Interesting why this has not been catched yet.

TODO: think about test case
---
 tools/tools.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/tools.h b/tools/tools.h
index c3d780d36..4b944e2fd 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -109,8 +109,8 @@ struct arg_values {
 
 struct arg_value_group_list {
         struct dm_list list;
-        struct arg_values arg_values[0];
 	uint32_t prio;
+        struct arg_values arg_values[0];
 };
 
 #define PERMITTED_READ_ONLY 	0x00000002


