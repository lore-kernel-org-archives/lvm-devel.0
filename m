From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:31 +0000 (UTC)
Subject: master - pv: issue different message of different type when we're overwriting existing PV header instead of creating a new one
Message-ID: <20160215120831.E24D160509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=73f1d444c8fccf7f0c95d09ff4b2a6c9f0e40e02
Commit:        73f1d444c8fccf7f0c95d09ff4b2a6c9f0e40e02
Parent:        52999133a36e5ab194dfa10d9108ca09ff1c930d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 10 14:19:20 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

pv: issue different message of different type when we're overwriting existing PV header instead of creating a new one

Scenario:

$ pvcreate /dev/sda
  Physical volume "/dev/sda" successfully created

We're adding the PV to a VG.

Before this patch:
$ vgcreate vg /dev/sda
  Physical volume "/dev/sda" successfully created
  Volume group "vg" successfully created

With this path applied:
$ vgcreate vg /dev/sda
  Volume group "vg" successfully created

...and verbose log containing: "Physical volume "/dev/sda" successfully written"
---
 lib/metadata/metadata.c |    8 +++++++-
 lib/metadata/vg.h       |    1 +
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a463754..90643fa 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -297,6 +297,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		}
 		pvw->pv = pv;
 		pvw->pp = new_pv ? pp : NULL;
+		pvw->new_pv = new_pv;
 		dm_list_add(&vg->pvs_to_write, &pvw->list);
 	}
 
@@ -1672,7 +1673,11 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 		return 0;
 	}
 
-	log_print_unless_silent("Physical volume \"%s\" successfully created", pv_name);
+	if (pvw->new_pv)
+		log_print_unless_silent("Physical volume \"%s\" successfully created", pv_name);
+	else
+		log_verbose("Physical volume \"%s\" successfully written", pv_name);
+
 	return 1;
 }
 
@@ -1791,6 +1796,7 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 		struct pv_to_write pvw;
 		pvw.pp = pp;
 		pvw.pv = pv;
+		pvw.new_pv = 1;
 		if (!_pvcreate_write(cmd, &pvw))
 			goto bad;
 	}
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 1c7c31c..f6c7bcc 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -36,6 +36,7 @@ struct pv_to_write {
 	struct dm_list list;
 	struct physical_volume *pv;
 	struct pvcreate_params *pp;
+	int new_pv;
 };
 
 #define MAX_EXTENT_COUNT  (UINT32_MAX)


