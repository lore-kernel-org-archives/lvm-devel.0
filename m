From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 28 Jan 2014 09:41:07 +0000 (UTC)
Subject: master - devices: support zvol
Message-ID: <20140128094107.5C590616A5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7786443530915505e17fcc42f0c750cb81cdc522
Commit:        7786443530915505e17fcc42f0c750cb81cdc522
Parent:        df181cc51e32fb54dac6652574e303e93b51b8bd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 27 13:13:32 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 28 10:33:29 2014 +0100

devices: support zvol

Support partitions on ZFS zvol.
Requested via https://bugzilla.redhat.com/show_bug.cgi?id=913597

Author: hakimian at aha.com
---
 WHATS_NEW                 |    1 +
 lib/device/device-types.h |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f56ad20..ca56623 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Add support for partitions on ZFS zvol.
   Fix unwanted drop of hold flocks on forked children.
   Respect LVM_LVMETAD_PIDFILE env var for lvm command.
   Avoid exposing temporary devices when initializing thin pool volume.
diff --git a/lib/device/device-types.h b/lib/device/device-types.h
index d716878..666f7b6 100644
--- a/lib/device/device-types.h
+++ b/lib/device/device-types.h
@@ -62,5 +62,6 @@ static const dev_known_type_t _dev_known_types[] = {
 	{"scm", 8, "Storage Class Memory (IBM S/390)"},
 	{"bcache", 1, "bcache block device cache"},
 	{"nvme", 64, "NVM Express"},
+	{"zvol", 16, "ZFS Zvols"},
 	{"", 0, ""}
 };


