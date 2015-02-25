From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 25 Feb 2015 17:01:27 +0000 (UTC)
Subject: master - vgcfgbackup: enable foreign VG access
Message-ID: <20150225170127.327956025F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aa30e95271734d213440dd1150e2bdc7c9f4f171
Commit:        aa30e95271734d213440dd1150e2bdc7c9f4f171
Parent:        8668a9e81c5bde921c9c8e6ba1162c5d4f7ffbe5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 25 11:01:37 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 25 11:01:37 2015 -0600

vgcfgbackup: enable foreign VG access

Backup of a foreign VG is allowed.
---
 tools/commands.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 3cb8f56..5cd7c2d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -908,7 +908,7 @@ xx(tags,
 
 xx(vgcfgbackup,
    "Backup volume group configuration(s)",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
    "vgcfgbackup\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"


