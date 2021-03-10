From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:58:10 +0000 (GMT)
Subject: main - toollib: preserve return code 5
Message-ID: <20210310235810.EBDB43857C62@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=236a45dfc5e0292c99240aaeef42591c77a28549
Commit:        236a45dfc5e0292c99240aaeef42591c77a28549
Parent:        4bbaff1fa621353d0d2adbbf86dd26284b8a11e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 11 00:54:32 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 11 00:56:43 2021 +0100

toollib: preserve return code 5

---
 tools/toollib.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/toollib.c b/tools/toollib.c
index a8bda8bcd..67fbbdaa0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4463,6 +4463,7 @@ int process_each_pv(struct cmd_context *cmd,
 		ret_max = ret;
 		if (ret_max == ECMD_FAILED)
 			goto_out;
+		ret_max = ECMD_FAILED; /* but ATM we've returned FAILED for all cases */
 	}
 
 	ret = _process_pvs_in_vgs(cmd, read_flags, &all_vgnameids, &all_devices,


