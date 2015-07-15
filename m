From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Jul 2015 14:26:34 +0000 (UTC)
Subject: master - vgimport: fix the all VGs case
Message-ID: <20150715142634.569B46007A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e15db1592642d5eb0a2a76b35882502c541302c7
Commit:        e15db1592642d5eb0a2a76b35882502c541302c7
Parent:        2972604f0c189217e9f46280798bd01243d37f83
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 15 09:26:10 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 15 09:26:10 2015 -0500

vgimport: fix the all VGs case

The ALL_VGS_IS_DEFAULT flag was wrongly removed;
it is needed for vgimport -a to work.
---
 tools/commands.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index bab7bc9..7f4b4e2 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1229,7 +1229,7 @@ xx(vgextend,
 
 xx(vgimport,
    "Register exported volume group with system",
-   0,
+   ALL_VGS_IS_DEFAULT,
    "vgimport\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"


