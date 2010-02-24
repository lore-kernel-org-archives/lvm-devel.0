From: Milan Broz <mbroz@redhat.com>
Date: Wed, 24 Feb 2010 12:46:51 +0100
Subject: [PATCH 1/2] Always query device by uuid only.
In-Reply-To: <20100223203902.GA31973@redhat.com>
References: <1266932816-5621-1-git-send-email-mbroz@redhat.com>
	<20100223203902.GA31973@redhat.com>
Message-ID: <4B8511AB.3080305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On 02/23/2010 09:39 PM, Mike Snitzer wrote:

> Also, _add_dev_to_dtree() is the only remaining caller of _info() that
> passes 'name'.  Passing a NULL 'name' to _info() from _add_dev_to_dtree()
> still allows the testsuite to pass.  What are the benefit(s) of
> preserving _info()'s info-by-name fallback for _add_dev_to_dtree()?

user for name paramater is lv_mknodes() and my patch was wrong here,
name must be still passed into that function.

_add_dev_to_dtree() should use NULL for name...

Thanks.

Milan

---
 lib/activate/dev_manager.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 84f94ff..2ec9b6f 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -254,8 +254,8 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 		return 0;
 	}
 
-	log_debug("Getting device info for %s", name);
-	r = _info(NULL, dlid, with_mknodes, with_open_count,
+	log_debug("Getting device info for %s [%s]", name, dlid);
+	r = _info(name, dlid, with_mknodes, with_open_count,
 		  with_read_ahead, info, read_ahead);
 
 	dm_pool_free(mem, (char*)name);
@@ -785,7 +785,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 
 	log_debug("Getting device info for %s [%s]", name, dlid);
-	if (!_info(name, dlid, 0, 1, 0, &info, NULL)) {
+	if (!_info(NULL, dlid, 0, 1, 0, &info, NULL)) {
 		log_error("Failed to get info for %s [%s].", name, dlid);
 		return 0;
 	}



