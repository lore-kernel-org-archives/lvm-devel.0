From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:06:02 -0400
Subject: [PATCH 29/35] Set vg_mda_copies when pvchange --metadataignore is given.
In-Reply-To: <1277175968-9661-29-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-8-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-9-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-10-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-12-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-13-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-14-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-15-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-16-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-17-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-18-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-19-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-20-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-21-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-22-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-23-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-24-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-25-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-26-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-27-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-28-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-29-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-30-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When a user explicitly sets a new mda ignore value for a PV, we
should update vg_mda_copies accordingly.  When the VG is written
out, the user would not want the new ignore state to get lost as
a result of the metadata balancing policy.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/pvchange.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index ba196d6..7f02073 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -147,6 +147,18 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		if (!pv_mda_set_ignored(pv, mda_ignore)) {
 			goto out;
 		}
+		/*
+		 * Update vg_mda_copies based on the mdas in this PV.
+		 * This is most likely what the usre would expect - if they
+		 * specify a specific PV to be ignored/un-ignored, they will
+		 * most likely not want LVM to turn around and change the
+		 * ignore / un-ignore value when it writes the VG to disk.
+		 * This does not guarantee this PV's ignore bits will be
+		 * preserved in future operations.
+		 */
+		if (!is_orphan(pv) && vg_mda_copies(vg)) {
+			vg_set_mda_copies(vg, vg_mda_copies(vg));
+		}
 	} else {
 		/* --uuid: Change PV ID randomly */
 		if (!id_create(&pv->id)) {
-- 
1.6.0.6


