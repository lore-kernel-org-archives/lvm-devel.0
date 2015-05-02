From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  2 May 2015 00:54:16 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150502005416.AC80961034@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bee2df3903d0956ba2e09ce9ae9ae55dfc5d3fd1
Commit:        bee2df3903d0956ba2e09ce9ae9ae55dfc5d3fd1
Parent:        796dc9c91c2da05a65054e4892eda41415c9898e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat May 2 01:41:17 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat May 2 01:41:17 2015 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |   13 +++++++++++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 3325ba1..d0c44b4 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.119(2)-git (2015-03-24)
+2.02.119(2)-git (2015-05-02)
diff --git a/VERSION_DM b/VERSION_DM
index 9a34d79..0236ba8 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.96-git (2015-03-24)
+1.02.96-git (2015-05-02)
diff --git a/WHATS_NEW b/WHATS_NEW
index 9d30df4..37812f6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
-Version 2.02.119 - 
-==================================
+Version 2.02.119 - 2nd May 2015
+===============================
+  New LVM_LOG_FILE_EPOCH, LVM_EXPECTED_EXIT_STATUS env vars. Man page to follow.
+  Remove detailed content from lvm.conf man page: use lvmconfig instead.
   Generate complete config files with lvmconfig or 'make generate'.
   Also display info on deprecated config with lvmconfig --withcomments.
   Display version since which config is deprecated in lvmconfig --withversions.
@@ -21,18 +23,25 @@ Version 2.02.119 -
   Refactor shared pvmove and lvconvert code into new _poll files.
   Add --unconfigured option to dumpconfig to print strings unconfigured.
   Add --withsummary option to dumpconfig to print first line - summary comment.
+  Use number of device holders to help choose between duplicate PVs.
+  Try to make lvmetad and non-lvmetad duplicate PV handling as similar as poss.
+  Issue warnings about duplicate PVs discovered by lvmetad.
+  Track alternative devices with matching PVIDs in lvmetad.
   Check for lvm binary in blkdeactivate and skip LVM processing if not present.
   Add --enable-halvm and --disable-halvm options to lvmconf script.
   Add --services, --mirrorservice and --startstopservices option to lvmconf.
   Use proper default value of global/use_lvmetad when processing lvmconf script.
   Respect allocation/cling_tag_list during intial contiguous allocation.
   Add A_PARTITION_BY_TAGS set when allocated areas should not share tags.
+  Make changes persist with python addTag/removeTag.
   Set correct vgid when updating cache when writing PV metadata.
   More efficient clvmd singlenode locking emulation.
+  Reject lvcreate -m with raid4/5/6 to avoid unexpected layout.
   Don't skip invalidation of cached orphans if vg write lck is held (2.02.118).
   Log relevant PV tags when using cling allocation.
   Add str_list_add_list() to combine two lists.
   Fix LV processing with selection to always do the selection on initial state.
+  Add internal LV_REMOVED LV status flag.
 
 Version 2.02.118 - 23rd March 2015
 ==================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dda91a2..684c1a6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.96 - 
-=================================
+Version 1.02.96 - 2nd May 2015
+==============================
   Fix selection to not match if using reserved value in criteria with >,<,>=,<.
   Fix selection to not match reserved values for size fields if using >,<,>=,<.
   Include uuid or device number in log message after ioctl failure.


