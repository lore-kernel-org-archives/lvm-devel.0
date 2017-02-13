From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:09:54 +0000 (UTC)
Subject: master - lvmlockd: test mode doesn't work
Message-ID: <20170213180954.D3D9860CD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19267fa6aa0709e3d0c962ad0904920f06102a5b
Commit:        19267fa6aa0709e3d0c962ad0904920f06102a5b
Parent:        2923d9e47deb11b28b8b753dd7862da186da051c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 15 11:49:19 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvmlockd: test mode doesn't work

The --test option is not yet compatible with shared VGs
because changes are made in lvmlockd that cannot be
reversed or faked.
---
 lib/metadata/metadata.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b11d306..1b500ed 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5629,6 +5629,11 @@ static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg
 		}
 	}
 
+	if (test_mode()) {
+		log_error("Test mode is not yet supported with lock type %s.", vg->lock_type);
+		return 0;
+	}
+
 	return 1;
 }
 


