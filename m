From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 20 Nov 2014 07:53:51 +0000 (UTC)
Subject: master - toollib: release vg on ignore path
Message-ID: <20141120075351.E6762615F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e55c6999ae62506dd8798451bb95d7a3aa7da765
Commit:        e55c6999ae62506dd8798451bb95d7a3aa7da765
Parent:        a61c5c5b3a88716697fcebe49c822ad6d5f4f66a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 20 08:52:44 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 20 08:53:30 2014 +0100

toollib: release vg on ignore path

Missing call to release_vg().
---
 tools/toollib.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 30dc980..d33de79 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2201,6 +2201,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
+			release_vg(vg);
 			continue;
 		}
 		


