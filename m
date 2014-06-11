From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Jun 2014 09:11:42 +0000 (UTC)
Subject: master - man: kiB uppercase
Message-ID: <20140611091142.E59A560EE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4db71422a243ac915ec835a46031f8458f0a8648
Commit:        4db71422a243ac915ec835a46031f8458f0a8648
Parent:        d13efac51b7a191e02106fcf467b64f3929eeb2d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 11 10:54:19 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 11 11:10:56 2014 +0200

man: kiB uppercase

---
 man/lvchange.8.in |    4 ++--
 man/lvcreate.8.in |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index ce10012..5c896e0 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -154,13 +154,13 @@ immediately poll a logical volume when it is activated, use
 .IR \fB\-\-[raid]maxrecoveryrate " " \fIRate [ bBsSkKmMgG ]
 Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
-If no suffix is given, then kiB/sec/device is assumed.  Setting the
+If no suffix is given, then KiB/sec/device is assumed.  Setting the
 recovery rate to 0 means it will be unbounded.
 .TP
 .IR \fB\-\-[raid]minrecoveryrate " " \fIRate [ bBsSkKmMgG ]
 Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
-If no suffix is given, then kiB/sec/device is assumed.  Setting the
+If no suffix is given, then KiB/sec/device is assumed.  Setting the
 recovery rate to 0 means it will be unbounded.
 .TP
 .BR \-\-[raid]syncaction " {" \fIcheck | \fIrepair }
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 64468a0..9892c21 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -316,13 +316,13 @@ Without this option a default name of "lvol#" will be generated where
 .IR \fB\-\-[raid]maxrecoveryrate " " \fIRate [ bBsSkKmMgG ]
 Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
-If no suffix is given, then kiB/sec/device is assumed.  Setting the
+If no suffix is given, then KiB/sec/device is assumed.  Setting the
 recovery rate to 0 means it will be unbounded.
 .TP
 .IR \fB\-\-[raid]minrecoveryrate " " \fIRate [ bBsSkKmMgG ]
 Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
-If no suffix is given, then kiB/sec/device is assumed.  Setting the
+If no suffix is given, then KiB/sec/device is assumed.  Setting the
 recovery rate to 0 means it will be unbounded.
 .TP
 .B \-\-noudevsync


