From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 30 Jun 2014 09:02:58 +0000 (UTC)
Subject: master - activation: fix typo in 'activation skip' message
Message-ID: <20140630090258.2621660A9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6fe906956cb7bdaa9b3ef43c14f8e6155483d7e
Commit:        b6fe906956cb7bdaa9b3ef43c14f8e6155483d7e
Parent:        100342605ce4a304b397665682d2ec555af5aa27
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 30 11:02:45 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 30 11:02:45 2014 +0200

activation: fix typo in 'activation skip' message

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 05293f1..9581942 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5887,7 +5887,7 @@ int lv_activation_skip(struct logical_volume *lv, activation_change_t activate,
 	    override_lv_skip_flag)
 		return 0;
 
-	log_verbose("ACTIVATON_SKIP flag set for LV %s/%s, skipping activation.",
+	log_verbose("ACTIVATION_SKIP flag set for LV %s/%s, skipping activation.",
 		    lv->vg->name, lv->name);
 	return 1;
 }


