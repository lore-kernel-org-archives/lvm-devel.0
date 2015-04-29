From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 29 Apr 2015 21:28:44 +0000 (UTC)
Subject: master - man: lvmthin section about use-policies
Message-ID: <20150429212844.154D460FF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=299a3be0d3d02e96794bb2c36217955c2b03f049
Commit:        299a3be0d3d02e96794bb2c36217955c2b03f049
Parent:        bf73ccb8483219c72cb7e80daf2e40f0a14db4e1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 29 10:00:38 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 29 16:27:40 2015 -0500

man: lvmthin section about use-policies

---
 man/lvmthin.7.in |  118 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 116 insertions(+), 2 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index dab2d7e..79ca40a 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -254,6 +254,8 @@ or vgchange to activate thin snapshots with the "k" attribute.
 .br
 .B Metadata space exhaustion
 .br
+.B Automatic extend settings
+.br
 .B Zeroing
 .br
 .B Discard
@@ -834,7 +836,8 @@ extended.  (Disabling dmeventd is not recommended.)
 .IP \[bu]
 Automatic extension of the thin pool is too slow given the rate of writes
 to thin LVs in the pool.  (This can be addressed by tuning the
-thin_pool_autoextend_threshold and thin_pool_autoextend_percent.)
+thin_pool_autoextend_threshold and thin_pool_autoextend_percent.
+See "Automatic extend settings".)
 
 .IP \[bu]
 The VG does not have enough free blocks to extend the thin pool.
@@ -877,6 +880,117 @@ repair.
 4. Check and repair file system with fsck.
 
 
+.SS Automatic extend settings
+
+\&
+
+Thin pool LVs can be extended according to preset values.  The presets
+determine if the LV should be extended based on how full it is, and if so
+by how much.  When dmeventd monitors thin pool LVs, it uses lvextend with
+these presets.  (See "Automatically extend thin pool LV".)
+
+Command to extend a thin pool data LV using presets:
+.br
+.B lvextend \-\-use\-policies VG/ThinPoolLV
+
+The command uses these settings:
+
+.BR lvm.conf (5)
+.B thin_pool_autoextend_threshold
+.br
+autoextend the LV when its usage exceeds this percent.
+
+.BR lvm.conf (5)
+.B thin_pool_autoextend_percent
+.br
+autoextend the LV by this much additional space.
+
+To see the default values of these settings, run:
+
+.B lvmconfig --type default --withcomment
+.RS
+.B activation/thin_pool_autoextend_threshold
+.RE
+
+.B lvmconfig --type default --withcomment
+.RS
+.B activation/thin_pool_autoextend_percent
+.RE
+
+To change these values globally, edit
+.BR lvm.conf (5).
+
+To change these values on a per-VG or per-LV basis, attach a "profile" to
+the VG or LV.  A profile is a collection of config settings, saved in a
+local text file (using the lvm.conf format).  lvm looks for profiles in
+the profile_dir directory, e.g. /etc/lvm/profile/.  Once attached to a VG
+or LV, lvm will process the VG or LV using the settings from the attached
+profile.  A profile is named and referenced by its file name.
+
+To use a profile to customize the lvextend settings for an LV:
+
+.IP \[bu] 2
+Create a file containing settings, saved in profile_dir.
+For the profile_dir location, run:
+.br
+.B lvmconfig config/profile_dir
+
+.IP \[bu] 2
+Attach the profile to an LV, using the command:
+.br
+.B lvchange \-\-metadataprofile ProfileName VG/ThinPoolLV
+
+.IP \[bu] 2
+Extend the LV using the profile settings:
+.br
+.B lvextend \-\-use\-policies VG/ThinPoolLV
+
+.P
+
+.I Example
+.br
+.nf
+# lvmconfig config/profile_dir
+profile_dir="/etc/lvm/profile"
+
+# cat /etc/lvm/profile/pool0extend.profile
+activation {
+        thin_pool_autoextend_threshold=50
+        thin_pool_autoextend_percent=10
+}
+
+# lvchange --metadataprofile pool0extend vg/pool0
+
+# lvextend --use-policies vg/pool0
+.fi
+
+.I Notes
+.IP \[bu] 2
+A profile is attached to a VG or LV by name, where the name references a
+local file in profile_dir.  If the VG is moved to another machine, the
+file with the profile also needs to be moved.
+
+.IP \[bu] 2
+Only certain settings can be used in a VG or LV profile, see:
+.br
+.B lvmconfig --type profilable-metadata.
+
+.IP \[bu] 2
+An LV without a profile of its own will inherit the VG profile.
+
+.IP \[bu] 2
+Remove a profile from an LV using the command:
+.br
+.B lvchange --detachprofile VG/ThinPoolLV.
+
+.IP \[bu] 2
+Commands can also have profiles applied to them.  The settings that can be
+applied to a command are different than the settings that can be applied
+to a VG or LV.  See lvmconfig --type profilable-command.  To apply a
+profile to a command, write a profile, save it in the profile directory,
+and run the command using the option: --commandprofile ProfileName.
+
+
 .SS Zeroing
 
 \&
@@ -1242,10 +1356,10 @@ skipped while mounting readonly:
 
 mount /dev/VG/SnapLV /mnt \-o ro,nouuid,norecovery
 
-
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvm.conf (5),
+.BR lvmconfig (8),
 .BR lvcreate (8),
 .BR lvconvert (8),
 .BR lvchange (8),


