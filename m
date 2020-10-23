From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Oct 2020 23:38:09 +0000 (GMT)
Subject: stable-2.02 - WHATS_NEW: update
Message-ID: <20201023233809.D7A6C386EC0B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5a2607bb194933caea62a88bd7fcc766efcd5cd
Commit:        f5a2607bb194933caea62a88bd7fcc766efcd5cd
Parent:        67dc22b95e7edfc3c0a96d96af313e7384908546
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 24 01:37:10 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 24 01:37:10 2020 +0200

WHATS_NEW: update

---
 WHATS_NEW | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 73167aca6..2a745dbdd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,8 @@
 Version 2.02.188 - 
 ==================================
-  Dmevend lvm plugin ignores higher reserved_stack lvm.conf values.
+  Enhance error handling for fsadm and hanled correct fsck result.
+  Stop logging rename errors from persintent filter.
+  Dmeventd lvm plugin ignores higher reserved_stack lvm.conf values.
   Support using BLKZEROOUT for clearing devices.
   Support interruption when wipping LVs.
   Add configure --enable-editline support as an alternative to readline.


