From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 12 Dec 2017 07:59:38 -0500
Subject: master - device: Internal error if writing 0 bytes to dev.
Message-ID: <201712121259.vBCCxcGT010103@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c5ef76bf27337406d48990acbfdaa869fd30f47b
Commit:        c5ef76bf27337406d48990acbfdaa869fd30f47b
Parent:        7272fd221096dbfd07e7ad11f0c938b453de2904
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 12 12:57:25 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 12 12:57:25 2017 +0000

device: Internal error if writing 0 bytes to dev.

---
 lib/device/dev-io.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index a9a9aac..dc9ad13 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -804,6 +804,11 @@ int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t r
 	if (!_dev_is_valid(dev))
 		return 0;
 
+	if (!len) {
+		log_error(INTERNAL_ERROR "Attempted to write 0 bytes to %s at " FMTu64, dev_name(dev), offset);
+		return 0;
+	}
+
 	where.dev = dev;
 	where.start = offset;
 	where.size = len;


