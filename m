From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 13 Jan 2014 10:57:09 +0000 (UTC)
Subject: master - report: Do not try to get dev_size of a NULL device.
Message-ID: <20140113105709.26CE460D93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d61c9eb52f05de5da706b79b9596143fab628b8e
Commit:        d61c9eb52f05de5da706b79b9596143fab628b8e
Parent:        5f7286f15d34d89b6710af3946985b4479e2a472
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jan 13 11:45:18 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jan 13 11:45:18 2014 +0100

report: Do not try to get dev_size of a NULL device.

---
 lib/report/report.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 2d39cb0..3626769 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -695,6 +695,9 @@ static int _devsize_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	uint64_t size;
 
+	if (!data)
+		return _field_set_value(field, "", NULL);
+
 	if (!dev_get_size(*(const struct device **) data, &size))
 		return_0;
 


