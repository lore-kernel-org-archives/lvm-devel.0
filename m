From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:22 +0000 (UTC)
Subject: dev-prajnoha-report-select - vgchange: Prompt when setting VG cluster attr if cluster is not setup
Message-ID: <20140606120322.DC2F760FA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9399b74356f9d0c2fbbac824908b15d63c3935cd
Commit:        9399b74356f9d0c2fbbac824908b15d63c3935cd
Parent:        de12310c457964e76e6558cbe079901a34ce4ef4
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Jun 5 22:27:40 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Jun 5 22:27:40 2014 -0500

vgchange: Prompt when setting VG cluster attr if cluster is not setup

If clvmd is not running or the locking type is not clustered and someone
attempts to set the cluster attribute on a volume group, prompt them to
see if they are sure.  (Only prompt for one though.  If neither are true,
simply ask them once.)
---
 tools/vgchange.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 05e7aea..478a8ca 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -317,6 +317,21 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (clustered) {
+		if (!dm_daemon_is_running(CLVMD_PIDFILE)) {
+			if (yes_no_prompt("LVM cluster daemon (clvmd) is not"
+					  " running.\n"
+					  "Make volume group \"%s\" clustered"
+					  " anyway? [y/n]: ", vg->name) == 'n')
+				return 0;
+
+		} else if (!locking_is_clustered() &&
+			   (yes_no_prompt("LVM locking type is not clustered.\n"
+					  "Make volume group \"%s\" clustered"
+					  " anyway? [y/n]: ", vg->name) == 'n'))
+			return 0;
+	}
+
 	if (!vg_set_clustered(vg, clustered))
 		return_0;
 


