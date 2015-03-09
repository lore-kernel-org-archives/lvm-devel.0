From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  9 Mar 2015 18:29:43 +0000 (UTC)
Subject: master - system_id: detect an lvm1 system id
Message-ID: <20150309182943.F088D60F64@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e9a233ee8ef362fccc5537125a19c28e5d596168
Commit:        e9a233ee8ef362fccc5537125a19c28e5d596168
Parent:        08371a8b8031b43394d80612d24029cfd4c710d4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 9 13:27:34 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 9 13:27:34 2015 -0500

system_id: detect an lvm1 system id

Detect an lvm1 system id by looking at the WRITE_LOCKED flag.
Don't copy this lvm1 system id into vg->system_id so that the
restrictions associated with the new system id are not applied
to the old VG with the inherited lvm1 system id.
---
 lib/format_text/import_vsn1.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 6afe71d..837af6b 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -812,6 +812,14 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
+	/*
+	 * A system id without WRITE_LOCKED is an old lvm1 system id.
+	 */
+	if (!(vg->status & LVM_WRITE_LOCKED) && system_id[0]) {
+		memcpy(vg->lvm1_system_id, system_id, NAME_LEN + 1);
+		memset(system_id, 0, NAME_LEN + 1);
+	}
+
 	if (vg->status & LVM_WRITE_LOCKED) {
 		vg->status |= LVM_WRITE;
 		vg->status &= ~LVM_WRITE_LOCKED;


