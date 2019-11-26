From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 26 Nov 2019 16:32:20 -0500
Subject: master - lvcreate: ensure striped raid region size is at least stripe size
Message-ID: <11018.119112616321401256@us-mta-395.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=29db9c6325ac3552b0ba3a0f49682e8e8112cca2
Commit:        29db9c6325ac3552b0ba3a0f49682e8e8112cca2
Parent:        2037476008ea42e79388a407355c7f285656a5d9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Nov 26 22:17:34 2019 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Nov 26 22:31:58 2019 +0100

lvcreate: ensure striped raid region size is at least stripe size

The kernel MD runtime requires region size to be larger than stripe size
on striped raid layouts, thus the dm-raid target's constructor rejects
such request.

This causes e.g. an 'lvcreate --type raid10 -i3 -I4096 -R2048 -n lv vg' to fail.

Avoid failing late in the kernel by enforcing region size to be
larger or equal to stripe size.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1698225
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e5af036..41d0e56 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.07 - 
 ===================================
+  Ensure minimum required region size on striped RaidLV creation.
   Fix resize of thin-pool with data and metadata of different segtype.
   Improve mirror type leg splitting.
   Fix activation order when removing merged snapshot.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index ebe6c9f..4a1534c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -575,6 +575,13 @@ static int _read_raid_params(struct cmd_context *cmd,
 			log_error("Minimum recovery rate cannot be higher than maximum.");
 			return 0;
 		}
+
+		if (lp->region_size < lp->stripe_size) {
+			log_print_unless_silent("Adjusting %s %s region size to required minimum of stripe size %s.",
+						lp->segtype->name, display_size(cmd, (uint64_t)lp->region_size),
+						display_size(cmd, (uint64_t)lp->stripe_size));
+			lp->region_size = lp->stripe_size;
+		}
 	}
 
 	return 1;



