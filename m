From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:15:52 +0000 (UTC)
Subject: master - WHATS_NEW: add lines for config validation support
Message-ID: <20130306111552.F010BA0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03b5c51730431ceb38c301293a19882b5829b84d
Commit:        03b5c51730431ceb38c301293a19882b5829b84d
Parent:        7d6991e900cbd5959e73285af81079bc22eadccb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 6 10:38:40 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 11:00:30 2013 +0100

WHATS_NEW: add lines for config validation support

---
 WHATS_NEW    |    5 +++++
 WHATS_NEW_DM |    2 ++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3a837aa..d7dda58 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,10 @@
 Version 2.02.99 - 
 ===================================
+  Add --validate option to lvm dumpconfig to validate current config on demand.
+  Add --ignoreadvanced and --ignoreunsupported switch to lvm dumpconfig.
+  Add --withcomments and --withversions switch to lvm dumpconfig.
+  Add --type {current|default|missing|new} and --atversion to lvm dumpconfig.
+  Support automatic config validation and add 'config' section to lvm.conf.
   Add pvs -o ea_start,ea_size to report embedding area start and size.
   Add --embeddingareasize to pvcreate and vgconvert to create an embedding area.
   Add PV header extension: extension version, flags and embedding areas.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9d9c53d..3bf8927 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.78 - 
 ===================================
+  Add dm_config_write_{node_out/one_node_out} for enhanced config output.
+  Add dm_config_value_is_bool to check for boolean value in supported formats.
   Fix config node lookup inside empty sections to not return the section itself.
   Extend support for status info of thin pool target.
   Fix segfault for truncated string token in config file after the first '"'.


