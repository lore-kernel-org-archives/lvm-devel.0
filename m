From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Jan 2020 10:47:37 -0500
Subject: master - fix corosync.conf: no interface error
Message-ID: <62641.120011510473201125@us-mta-21.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2f6d0a6408220a1f6a96a9f39779846578d88b8c
Commit:        2f6d0a6408220a1f6a96a9f39779846578d88b8c
Parent:        151bf52649ba7a5a6731693e5af8560f6cf1742a
Author:        Heming Zhao <heming.zhao@suse.com>
AuthorDate:    Wed Jan 15 02:17:47 2020 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 15 09:46:54 2020 -0600

fix corosync.conf: no interface error

systemctl status corosync (version: 2.4.5) report error:
  parse error in config: No interfaces defined

Signed-off-by: Zhao Heming <heming.zhao@suse.com>
---
 test/lib/test-corosync-conf | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/test/lib/test-corosync-conf b/test/lib/test-corosync-conf
index ccc958f..e04be73 100644
--- a/test/lib/test-corosync-conf
+++ b/test/lib/test-corosync-conf
@@ -3,6 +3,13 @@ totem {
         version: 2
         secauth: off
         cluster_name: test
+        interface {
+            ingnumber: 0
+            bindnetaddr: 127.0.0.1
+            mcastaddr: 239.255.255.100
+            mcastport: 5405
+            ttl: 1
+        }
 }
 nodelist {
         node {
@@ -12,6 +19,8 @@ nodelist {
 }
 quorum {
         provider: corosync_votequorum
+        expected_votes: 1
+        two_node: 0
 }
 logging {
         to_syslog: yes



