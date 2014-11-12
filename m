From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Nov 2014 08:48:46 +0000 (UTC)
Subject: master - coverity: fix compiler warning
Message-ID: <20141112084846.B4DF26052E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99bf77d8170a5e15a7631ceb2ef041cf67a3827f
Commit:        99bf77d8170a5e15a7631ceb2ef041cf67a3827f
Parent:        57c618b0edbea321626766d9de2a0640efdc2bc2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 12 09:42:53 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 12 09:48:34 2014 +0100

coverity: fix compiler warning

LVM2.2.02.112/lib/activate/dev_manager.c:196:5: warning: 'dmtask' may be used uninitialized in this function [-Wmaybe-uninitialized]

In _info_run fn:

switch (type) {
	case INFO:
		...
	case STATUS:
		...
	case MKNODES:
		...
}

The "type" is enum and currently only those three types are supported,
but if we added a new type in the future, this would end up with a bug
(if we forgot to add the new "case" in that "switch"). So let's make
sure proper internal error is printed:

	case default:
		log_error(INTERNAL_ERROR "_info_run: unhandled info type");
                return 0;
---
 lib/activate/dev_manager.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 18ecb3a..1d18dfb 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -191,6 +191,9 @@ static int _info_run(info_type_t type, const char *name, const char *dlid,
 		case MKNODES:
 			dmtask = DM_DEVICE_MKNODES;
 			break;
+		case default:
+			log_error(INTERNAL_ERROR "_info_run: unhandled info type");
+			return 0;
 	}
 
 	if (!(dmt = _setup_task(type != MKNODES ? name : NULL, dlid, 0, dmtask,


