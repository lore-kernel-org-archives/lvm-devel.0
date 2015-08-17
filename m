From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 17 Aug 2015 17:37:34 +0000 (UTC)
Subject: master - dmstats: check for zero in _nr_areas_from_step() (Coverity)
Message-ID: <20150817173734.55FB760139@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69fa16048a61b6cd0b8fe9c311dd4e9eea532207
Commit:        69fa16048a61b6cd0b8fe9c311dd4e9eea532207
Parent:        b01e9651b06a6362339d4c3d5d8da43896dae50f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 17 18:31:11 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 17 18:37:16 2015 +0100

dmstats: check for zero in _nr_areas_from_step() (Coverity)

---
 tools/dmsetup.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8bcf4d5..7769fde 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4434,6 +4434,10 @@ static int _size_from_string(char *argptr, uint64_t *size, const char *name)
  */
 static uint64_t _nr_areas_from_step(uint64_t len, int64_t step)
 {
+	/* Default is one area. */
+	if (!step || !len)
+		return 1;
+
 	/* --areas */
 	if (step < 0)
 		return (uint64_t)(-step);


