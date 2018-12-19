From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 19 Dec 2018 10:30:53 -0500
Subject: master - cov: Close a FD on error
Message-ID: <201812191530.wBJFUreH025489@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f05104af76e26f0757df1500540e767dd889ae71
Commit:        f05104af76e26f0757df1500540e767dd889ae71
Parent:        b068f21f6a24094936a33269067c18373b48f2cd
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Dec 19 16:29:31 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Dec 19 16:29:31 2018 +0100

cov: Close a FD on error

---
 tools/pvscan.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 2a884df..6841f20 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -290,7 +290,8 @@ static int _online_pvid_file_create(struct device *dev)
 		rv = write(fd, buf, len);
 		if (rv < 0) {
 			log_error("Failed to write fd %d buf %s dev %s to %s: %d",
-				  fd, buf, dev_name(dev), path, errno);
+			          fd, buf, dev_name(dev), path, errno);
+			close(fd);
 			return 0;
 		}
 		len -= rv;


