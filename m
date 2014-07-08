From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  8 Jul 2014 08:29:00 +0000 (UTC)
Subject: master - conf: comment out devices/preferred_names and filter setting
Message-ID: <20140708082900.422296017F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f76879ba440aa93f2e237335fe2cca6951a636bf
Commit:        f76879ba440aa93f2e237335fe2cca6951a636bf
Parent:        f6001465efe064611920b30f5b913c1d09004ded
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 8 10:22:59 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 8 10:22:59 2014 +0200

conf: comment out devices/preferred_names and filter setting

This avoids creating void matchers which have no effect anyway and
they just use resources. Also, it makes lvm dumpconfig --type diff
to mark these settings properly as not being different from defaults
(where by default, devices/preferred_names as well as devices/filter
are void).

Also, add a few comments about builtin rules used to select device
alias in case preferred_names is not defined or it doesn't match
any of device aliases.
---
 conf/example.conf.in |   23 +++++++++++++++++++++--
 1 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 162770a..e1afbb6 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -53,11 +53,30 @@ devices {
     # same block device and the tools need to display a name for device,
     # all the pathnames are matched against each item in the following
     # list of regular expressions in turn and the first match is used.
-    preferred_names = [ ]
+
+    # By default no preferred names are defined.
+    # preferred_names = [ ]
 
     # Try to avoid using undescriptive /dev/dm-N names, if present.
     # preferred_names = [ "^/dev/mpath/", "^/dev/mapper/mpath", "^/dev/[hs]d" ]
 
+    # In case no prefererred name matches or if preferred_names are not
+    # defined at all, builtin rules are used to determine the preference.
+    #
+    # The first builtin rule checks path prefixes and it gives preference
+    # based on this ordering (where "dev" depends on devices/dev setting):
+    #   /dev/mapper > /dev/disk > /dev/dm-* > /dev/block
+    #
+    # If the ordering above cannot be applied, the path with fewer slashes
+    # gets preference then.
+    #
+    # If the number of slashes is the same, a symlink gets preference.
+    #
+    # Finally, if all the rules mentioned above are not applicable,
+    # lexicographical order is used over paths and the smallest one
+    # of all gets preference.
+
+
     # A filter that tells LVM2 to only use a restricted set of devices.
     # The filter consists of an array of regular expressions.  These
     # expressions can be delimited by a character of your choice, and
@@ -84,7 +103,7 @@ devices {
     # lvmetad is used" comment that is attached to global/use_lvmetad setting.
 
     # By default we accept every block device:
-    filter = [ "a/.*/" ]
+    # filter = [ "a/.*/" ]
 
     # Exclude the cdrom drive
     # filter = [ "r|/dev/cdrom|" ]


