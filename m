From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed, 25 Jan 2017 16:22:34 +0000 (UTC)
Subject: master - man: add update_filemap to dmstats.8.in
Message-ID: <20170125162234.4B28A60E07@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2350ea0060cd729f36245df5622b38c4b8d9bb12
Commit:        2350ea0060cd729f36245df5622b38c4b8d9bb12
Parent:        b999d5f501bc959cad138e4a3a2459af90d0a3ca
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Dec 17 16:36:26 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jan 25 16:15:21 2017 +0000

man: add update_filemap to dmstats.8.in

---
 man/dmstats.8.in |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index c3ede01..167711c 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -212,6 +212,17 @@ dmstats \(em device-mapper statistics management
 .  ad b
 ..
 .CMD_UNGROUP
+.HP
+.B dmstats
+.de CMD_UPDATE_FILEMAP
+.  ad l
+.  BR update_filemap
+.  RI file_path
+.  RB [ \-\-groupid
+.  IR id ]
+.  ad b
+..
+.CMD_UPDATE_FILEMAP
 .
 .PD
 .ad b
@@ -668,6 +679,21 @@ Remove an existing group and return all the group's regions to their
 original state.
 
 The group to be removed is specified using \fB\-\-groupid\fP.
+.HP
+.CMD_UPDATE_FILEMAP
+.br
+Update a group of \fBdmstats\fP regions specified by \fBgroup_id\fP,
+that were previously created with \fB\-\-filemap\fP. This will add
+and remove regions to reflect changes in the allocated extents of
+the file on-disk, since the time that it was crated or last updated.
+
+Use of this command is not normally needed since the \fBdmfilemapd\fP
+daemon will automatically monitor filemap groups and perform these
+updates when required.
+
+If a filemapped group was created with \fB\-\-nominitor\fP, or the
+daemon has been killed, the \fBupdate_filemap\fP can be used to
+manually force an update.
 .
 .SH REGIONS, AREAS, AND GROUPS
 .


