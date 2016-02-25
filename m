From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 23:02:31 +0000 (UTC)
Subject: master - pvcreate: fix data alignment error check
Message-ID: <20160225230231.9C04B60BCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88530b2ef34527eae2bacc86c765fb680f5b6b2b
Commit:        88530b2ef34527eae2bacc86c765fb680f5b6b2b
Parent:        081359f6cd2ed8224992c91e99617ef576e01488
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 25 16:57:01 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 17:02:18 2016 -0600

pvcreate: fix data alignment error check

Make the data_alignment variable 64 bits so it
can hold the invalid command line arg used in
pvreate-usage.sh pvcreate --dataalignment 1e.

On 32 bit arches, the smaller variable wouldn't
hold the invalid value so the error would not
trigger as expected by the test.
---
 lib/metadata/metadata-exported.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 03e8572..6b39de4 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -522,8 +522,8 @@ struct vgnameid_list {
  */
 struct pv_create_args {
 	uint64_t size;
-	unsigned long data_alignment;
-	unsigned long data_alignment_offset;
+	uint64_t data_alignment;
+	uint64_t data_alignment_offset;
 	uint64_t label_sector;
 	int pvmetadatacopies;
 	uint64_t pvmetadatasize;


