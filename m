From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Mar 2016 10:52:02 +0000 (UTC)
Subject: master - man: lvrename: also mention possibility to rename historical logical volumes
Message-ID: <20160304105202.8A90261126@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e447ab87e904799dac89f70d32733d4368563d91
Commit:        e447ab87e904799dac89f70d32733d4368563d91
Parent:        fa06c2263b24561c25c04aefd93204f7cfc39543
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 4 11:51:57 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 4 11:51:57 2016 +0100

man: lvrename: also mention possibility to rename historical logical volumes

---
 man/lvrename.8.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/man/lvrename.8.in b/man/lvrename.8.in
index bba46ae..fdacac7 100644
--- a/man/lvrename.8.in
+++ b/man/lvrename.8.in
@@ -19,7 +19,8 @@ lvrename \(em rename a logical volume
 |
 .I VolumeGroupName OldLogicalVolumeName NewLogicalVolumeName\fR}
 .SH DESCRIPTION
-lvrename renames an existing logical volume from
+lvrename renames an existing logical volume or an existing
+historical logical volume from
 .IR OldLogicalVolume { Name | Path }
 to
 .IR NewLogicalVolume { Name | Path }.


