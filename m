From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:56 +0000 (UTC)
Subject: master - cleanup: use unsigned type for command
Message-ID: <20140702084856.A19F860BAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52ab15b2d0803fee480c404a458f3b568507a53a
Commit:        52ab15b2d0803fee480c404a458f3b568507a53a
Parent:        57f8b33d5de8c93ee48f4d1caa69ac3fd45d05d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 2 10:27:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:45:43 2014 +0200

cleanup: use unsigned type for command

Keep command unsigned (as _IOWR() produces them).
---
 libdm/ioctl/libdm-targets.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index 8fc8738..54223c7 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -74,7 +74,7 @@ struct dm_task {
 
 struct cmd_data {
 	const char *name;
-	const int cmd;
+	const unsigned cmd;
 	const int version[3];
 };
 


