From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Jul 2015 14:23:39 +0000 (UTC)
Subject: master - vgexport: fix the all VGs case
Message-ID: <20150715142339.7090960FCF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2972604f0c189217e9f46280798bd01243d37f83
Commit:        2972604f0c189217e9f46280798bd01243d37f83
Parent:        d947a815e8bc6080ee5b364bd55f8aa0c2807f4e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 15 09:21:45 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 15 09:23:30 2015 -0500

vgexport: fix the all VGs case

The ALL_VGS_IS_DEFAULT flag was wrongly removed;
it is needed for vgexport -a to work.
---
 tools/commands.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index e50505d..bab7bc9 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1191,7 +1191,7 @@ xx(vgdisplay,
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
-   0,
+   ALL_VGS_IS_DEFAULT,
    "vgexport\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"


