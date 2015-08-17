From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 17 Aug 2015 17:37:36 +0000 (UTC)
Subject: master - libdm: check for zero in _nr_areas() (Coverity)
Message-ID: <20150817173736.6F1D060139@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=074b5de7715b76ad63147f84edb5d9e1a05870e9
Commit:        074b5de7715b76ad63147f84edb5d9e1a05870e9
Parent:        69fa16048a61b6cd0b8fe9c311dd4e9eea532207
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 17 18:33:22 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 17 18:37:16 2015 +0100

libdm: check for zero in _nr_areas() (Coverity)

---
 libdm/libdm-stats.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index b7000cc..ba213b7 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -504,6 +504,9 @@ out:
 
 static uint64_t _nr_areas(uint64_t len, uint64_t step)
 {
+	/* Default is one area. */
+	if (!len || !step)
+		return 1;
 	/*
 	 * drivers/md/dm-stats.c::message_stats_create()
 	 * A region may be sub-divided into areas with their own counters.


