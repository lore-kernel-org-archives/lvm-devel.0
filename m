From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Feb 2013 18:08:11 +0000 (UTC)
Subject: master - cleanup: indent line
Message-ID: <20130204180811.87A813523@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b37a0a39e3c80abdab2c3dc4522411c7aa9eec5e
Commit:        b37a0a39e3c80abdab2c3dc4522411c7aa9eec5e
Parent:        d2eae42c0e3553fa13b8bc8f25b9c87fb2554861
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 19 12:04:17 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 4 19:01:11 2013 +0100

cleanup: indent line

---
 lib/config/config.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.h b/lib/config/config.h
index d789ade..5c36f4d 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -31,7 +31,7 @@ struct dm_config_tree *config_file_open(const char *filename, int keep_open);
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum);
-	int config_file_read(struct dm_config_tree *cft);
+int config_file_read(struct dm_config_tree *cft);
 int config_write(struct dm_config_tree *cft, const char *file,
 		 int argc, char **argv);
 void config_file_destroy(struct dm_config_tree *cft);


