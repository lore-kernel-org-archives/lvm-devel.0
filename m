From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:36 +0000 (UTC)
Subject: master - cleanup: fix some lvm.conf typos
Message-ID: <20140211180136.4FE1F60FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=108ae0edc6a6c4bb771fa7931fc1e709793ddadf
Commit:        108ae0edc6a6c4bb771fa7931fc1e709793ddadf
Parent:        9d69585b82d8bc2305f7ac197ef22751f9821a5f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 11 18:05:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 19:00:06 2014 +0100

cleanup: fix some lvm.conf typos

---
 conf/example.conf.in |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 08ce877..1572750 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -336,14 +336,14 @@ allocation {
     # thin_pool_chunk_size_policy = "generic"
 
     # Specify the minimal chunk size (in KB) for thin pool volumes.
-    # Use of the larger chunk size may improve perfomance for plain
+    # Use of the larger chunk size may improve performance for plain
     # thin volumes, however using them for snapshot volumes is less efficient,
     # as it consumes more space and takes extra time for copying.
     # When unset, lvm tries to estimate chunk size starting from 64KB
     # Supported values are in range from 64 to 1048576.
     # thin_pool_chunk_size = 64
 
-    # Specify discards behavior of the thin pool volume.
+    # Specify discards behaviour of the thin pool volume.
     # Select one of  "ignore", "nopassdown", "passdown"
     # thin_pool_discards = "passdown"
 
@@ -423,7 +423,7 @@ log {
 # Configuration of metadata backups and archiving.  In LVM2 when we
 # talk about a 'backup' we mean making a copy of the metadata for the
 # *current* system.  The 'archive' contains old metadata configurations.
-# Backups are stored in a human readeable text format.
+# Backups are stored in a human readable text format.
 backup {
 
     # Should we maintain a backup of the current metadata configuration ?
@@ -614,7 +614,7 @@ global {
     # "mirror" - LVM will layer the 'mirror' and 'stripe' segment types.  It
     #            will do this by creating a mirror on top of striped sub-LVs;
     #            effectively creating a RAID 0+1 array.  This is suboptimal
-    #            in terms of providing redunancy and performance.  Changing to
+    #            in terms of providing redundancy and performance. Changing to
     #            this setting is not advised.
     # Specify the '--type <raid10|mirror>' option to override this default
     # setting.
@@ -678,7 +678,7 @@ global {
     # Array of string options passed with thin_check command. By default,
     # option "-q" is for quiet output.
     # With thin_check version 2.1 or newer you can add "--ignore-non-fatal-errors"
-    # to let it pass through ignoreable errors and fix them later.
+    # to let it pass through ignorable errors and fix them later.
     #
     # thin_check_options = [ "-q" ]
 
@@ -838,7 +838,7 @@ activation {
     # auto_set_activation_skip = 1
 
     # For RAID or 'mirror' segment types, 'raid_region_size' is the
-    # size (in kiB) of each:
+    # size (in KiB) of each:
     # - synchronization operation when initializing
     # - each copy operation when performing a 'pvmove' (using 'mirror' segtype)
     # This setting has replaced 'mirror_region_size' since version 2.02.99


