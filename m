From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:15 +0000 (UTC)
Subject: master - topology: handle reported sizes smaller then sector
Message-ID: <20160310174015.7537560EB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5aade9c402e2195bc1742509300983b0d77f33e8
Commit:        5aade9c402e2195bc1742509300983b0d77f33e8
Parent:        a494d85ef6cf00a6a61707e5bc41aa59bb17b7e6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 3 20:53:08 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:54 2016 +0100

topology: handle reported sizes smaller then sector

Recent kernel (4.4) start to report values smaller then sector size
(but in reporting size for SSD which support data zeroing on discard).

For now log warning and assume it really means 1 sector.

Addressing RHBZ:
https://bugzilla.redhat.com/show_bug.cgi?id=1313377
---
 lib/device/dev-type.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index a6223dc..689809a 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -853,6 +853,12 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 
 	result = value >> SECTOR_SHIFT;
 
+	if (!result && value) {
+		log_warn("WARNING: Device %s: %s is %lu and is unexpectedly less then sector.",
+			 dev_name(dev), attribute, value);
+		result = 1;
+	}
+
 out_close:
 	if (fclose(fp))
 		log_sys_debug("fclose", path);


