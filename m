From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  5 Dec 2013 01:14:54 +0000 (UTC)
Subject: master - lvmetad: remove unused override variables
Message-ID: <20131205011454.9CFC8603A0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ac6cd9baa7dac621cae58d545080599dcc281413
Commit:        ac6cd9baa7dac621cae58d545080599dcc281413
Parent:        b6d3fd62fc87bcdc6a12b7751e36a6a84b0bb62d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Dec 5 01:13:18 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Dec 5 01:13:18 2013 +0000

lvmetad: remove unused override variables

---
 daemons/lvmetad/lvmetad-core.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 2810faf..bc306f3 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1197,8 +1197,6 @@ int main(int argc, char *argv[])
 {
 	signed char opt;
 	lvmetad_state ls;
-	int _pidfile_override = 1;
-	int _socket_override = 1;
 	daemon_state s = {
 		.daemon_fini = fini,
 		.daemon_init = init,
@@ -1211,15 +1209,11 @@ int main(int argc, char *argv[])
 		.socket_path = getenv("LVM_LVMETAD_SOCKET"),
 	};
 
-	if (!s.pidfile) {
-		_pidfile_override = 0;
+	if (!s.pidfile)
 		s.pidfile = LVMETAD_PIDFILE;
-	}
 
-	if (!s.socket_path) {
-		_socket_override = 0;
+	if (!s.socket_path)
 		s.socket_path = LVMETAD_SOCKET;
-	}
 
 	ls.log_config = "";
 
@@ -1240,11 +1234,9 @@ int main(int argc, char *argv[])
 			break;
 		case 'p':
 			s.pidfile = optarg;
-			_pidfile_override = 1;
 			break;
 		case 's': // --socket
 			s.socket_path = optarg;
-			_socket_override = 1;
 			break;
 		case 'V':
 			printf("lvmetad version: " LVM_VERSION "\n");


