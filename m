From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 25 Feb 2015 14:22:34 +0000 (UTC)
Subject: master - example.conf: Update systemid comments.
Message-ID: <20150225142234.0EB4360D59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e59c0346a3d9f5d125708529bd6d2ff4d0a16d5
Commit:        1e59c0346a3d9f5d125708529bd6d2ff4d0a16d5
Parent:        809a5e142eec520aab2702fd3b8cfafc1d16ffac
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Feb 25 14:22:24 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Feb 25 14:22:24 2015 +0000

example.conf: Update systemid comments.

Avoid using 'cluster' (ambiguous).
Add holding ref for machine-id source.
---
 conf/example.conf.in |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 574842a..1f10dad 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -840,8 +840,8 @@ global {
 
     # The method, if any, used to define a local system ID on this host.
     # By placing the same system ID on a Volume Group you can prevent
-    # other co-operating hosts in a cluster (each with a different
-    # system ID) from accessing the same Volume Group.
+    # other co-operating hosts that see the same storage devices (each 
+    # with a different system ID) from accessing the same Volume Group.
     #
     # Set this to one of: none, machineid, uname, lvmlocal, or file.
     #
@@ -861,8 +861,8 @@ global {
     # system_id_source = "uname"
     #
     # Use the contents of the file @DEFAULT_SYS_DIR@/machine-id
-    # to set the system ID.
-    # Comments starting with the character # are ignored.
+    # to set the system ID.  Some systems create this file at
+    # installation time - see 'man machine-id'.
     #
     # system_id_source = "machineid"
     #


