From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 13 Jan 2014 10:57:11 +0000 (UTC)
Subject: master - reporter: Set labeller on dummy labels (fixes missing fmt field).
Message-ID: <20140113105711.42A2660D93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c445f3c2c1553ff1e9f97c2302344736e7f35e8
Commit:        9c445f3c2c1553ff1e9f97c2302344736e7f35e8
Parent:        d61c9eb52f05de5da706b79b9596143fab628b8e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jan 13 11:45:38 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jan 13 11:45:38 2014 +0100

reporter: Set labeller on dummy labels (fixes missing fmt field).

---
 tools/reporter.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index bf181e7..a36fcb3 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -183,6 +183,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	/* FIXME workaround for pv_label going through cache; remove once struct
 	 * physical_volume gains a proper "label" pointer */
 	if (!(label = pv_label(pv))) {
+		_dummy_label.labeller = pv->fmt->labeller;
 		if (pv->dev)
 			_dummy_label.dev = pv->dev;
 		else {


