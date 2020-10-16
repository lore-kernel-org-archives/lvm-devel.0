From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:51 +0000 (GMT)
Subject: stable-2.02 - tools: move struct element before variable lenght list
Message-ID: <20201016191051.A65B5396E814@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2839912d12a67d1795e49bfcf8f2bb949d4344de
Commit:        2839912d12a67d1795e49bfcf8f2bb949d4344de
Parent:        86056c56f4b3638d160f874c664d91f403249386
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 19:15:42 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:06 2020 +0200

tools: move struct element before variable lenght list

Move prio field before 'variable' struct array field.
Interesting why this has not been catched yet.

TODO: think about test case
---
 tools/tools.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/tools.h b/tools/tools.h
index 5fe3ba86f..4744357f0 100644
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


