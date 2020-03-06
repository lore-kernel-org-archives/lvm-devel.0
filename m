From: David Teigland <teigland@sourceware.org>
Date: Fri, 6 Mar 2020 10:06:24 -0500
Subject: stable-2.02 - pvs: fix locking_type 4
Message-ID: <202003061506.026F6OG4023239@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=20d61a2553a160570835cad6790108fa2365b936
Commit:        20d61a2553a160570835cad6790108fa2365b936
Parent:        deaf304ee6d88cd47632a345b92b3949cd06d752
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 3 12:59:20 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 6 09:06:10 2020 -0600

pvs: fix locking_type 4

Fix for commit 79c4971210a6337563ffa2fca08fb636423d93d4.
This bug leads lvm to attempt a bogus recovery of the
orphan VG whenever the orphan VG is read.
No recovery code exists for the orphan VG, but lvm still
attempts it when the "consistent" variable is not set to 1.

When lvm attempts the bogus/no-op orphan recovery, it tries
to get a write lock.  Usually the write lock succeeds, and
"recovery" does nothing, so fairly harmless.  But, with
locking_type=4, the write lock fails, which bubbles up to
cause the whole command failure.
---
 lib/metadata/metadata.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 81a6029..666ad78 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3433,6 +3433,8 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 
 	dm_list_init(&head.list);
 
+	*consistent = 1;
+
 	if (!(vginfo = lvmcache_vginfo_from_vgname(orphan_vgname, NULL)))
 		return_NULL;
 



