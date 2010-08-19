From: Christoph Anton Mitterer <calestyo@scientia.net>
Date: Fri, 20 Aug 2010 01:58:46 +0200
Subject: patch4/4: lvm manpages
Message-ID: <1282262326.3337.97.camel@fermat.scientia.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

4) lvm.8.misc.patch
- Some (IMHO) typos,... please check whether I'm really correct
everywhere
(especially the large->larger change).
- For the allowed characters in VG/LV names and tags, use the same
ordering
in both places they're listed.




--- lvm.8	2010-06-24 00:34:43.702027000 +0200
+++ 1	2010-06-24 00:36:10.377776836 +0200
@@ -175,7 +175,7 @@
 If you set this to \fBn\fP, no attempt will be made to contact the
driver.
 .TP
 \fB-A | --autobackup\fP { \fBy\fP | \fBn\fP }
-Whether or not to metadata should be backed up automatically after a
change.  
+Whether or not metadata should be backed up automatically after a
change.  
 You are strongly advised not to disable this!
 See
 .B vgcfgbackup (8).
@@ -188,7 +188,7 @@
 \fBdmsetup (8)\fP to set this up to return I/O errors when accessed,
 or create it as a large block device of nulls.  Metadata may not be
 changed with this option. To insert a replacement physical volume
-of the same or large size use \fBpvcreate -u\fP to set the uuid to 
+of the same or larger size use \fBpvcreate -u\fP to set the uuid to 
 match the original followed by \fBvgcfgrestore (8)\fP.
 .TP
 \fB-M | --metadatatype type\fP
@@ -266,7 +266,7 @@
 Not set by default.
 .SH VALID NAMES
 The following characters are valid for VG and LV names:
-\fBa-z A-Z 0-9 + _ . -\fP
+\fBA-Z a-z 0-9 _ + . -\fP
 .LP
 VG and LV names cannot begin with a hyphen.
 There are also various reserved names that are used internally by lvm
that can not be used as LV or VG names.


