From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 26 Nov 2019 16:31:21 -0500
Subject: stable-2.02 - lvcreate: ensure striped raid region size is at least stripe size
Message-ID: <66652.119112616311601662@us-mta-411.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50c56ade2a7a89f751091669fb8b31854f93eff1
Commit:        50c56ade2a7a89f751091669fb8b31854f93eff1
Parent:        61c321d110630d4fc2ed8f75cb3a9ba78e29599b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Nov 26 22:17:34 2019 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Nov 26 22:30:54 2019 +0100

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
index 50fd519..047479b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.187 - 
 ===================================
+  Ensure minimum required region size on striped RaidLV creation.
   Fix resize of thin-pool with data and metadata of different segtype.
   Fix splitting mirror leg in cluster.
   Fix activation order when removing merged snapshot.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 6e8cc90..c27b798 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -574,6 +574,13 @@ static int _read_raid_params(struct cmd_context *cmd,
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



