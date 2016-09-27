From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 27 Sep 2016 17:25:02 +0000 (UTC)
Subject: master - lvconvert: Disable thin pool raid conversion while active.
Message-ID: <20160927172502.37EA960ED2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1bc546269a7d2cae156827e282715410a4967d51
Commit:        1bc546269a7d2cae156827e282715410a4967d51
Parent:        56c90ffa5e7d7c69c5230ac3bbee3ed03e7bae62
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Sep 27 18:22:54 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Sep 27 18:22:54 2016 +0100

lvconvert: Disable thin pool raid conversion while active.

Works if the pool is inactive.

Activation code doesn't notice a new raid dependency in on-disk metadata
when a thin LV is already active.

https://bugzilla.redhat.com/1365286
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aa6c0c6..b0140be 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.167 - 
 ======================================
+  Disable lvconvert of thin pool to raid while active.
   Disable systemd service start rate limiting for lvm2-pvscan at .service.
 
 Version 2.02.166 - 26th September 2016
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index deb88a2..f8a3c46 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -776,6 +776,11 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_is_active(lv_lock_holder(lv)) && (old_count == 1) && (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv))) {
+		log_error("Can't add image to active thin pool LV %s yet. Deactivate first.", display_lvname(lv));
+		return 0;
+	}
+
 	if (!archive(lv->vg))
 		return_0;
 


