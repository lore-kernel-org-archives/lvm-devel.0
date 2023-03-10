From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 10 Mar 2023 18:52:28 +0000 (GMT)
Subject: main - lvmdbustest: open log file with "a"
Message-ID: <20230310185228.B4340385842B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=70a5ebc052e7873761c04679ed8e57cd5f20e91a
Commit:        70a5ebc052e7873761c04679ed8e57cd5f20e91a
Parent:        1949afa24b10991408cff362084cdc881f499535
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 11:22:51 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 10 12:51:53 2023 -0600

lvmdbustest: open log file with "a"

So we retain the log across fork & exec and lvm shell testing.
---
 test/dbus/lvm_error_inject.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/dbus/lvm_error_inject.py b/test/dbus/lvm_error_inject.py
index 454b80171..00653d67f 100755
--- a/test/dbus/lvm_error_inject.py
+++ b/test/dbus/lvm_error_inject.py
@@ -36,7 +36,7 @@ def rs(length, character_set=CS):
 
 RS = rs(512)
 
-d_out = open("/tmp/mitm_lvm.txt", "w+")
+d_out = open("/tmp/mitm_lvm.txt", "a")
 
 
 def debug(msg):

