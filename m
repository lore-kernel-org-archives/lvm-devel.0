From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Sep 2021 13:26:28 +0000 (GMT)
Subject: main - clang: free on arg parsing
Message-ID: <20210915132628.BA9FB3858413@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73087c2c0fd51b1ff543580dadbf3d02dd49a35d
Commit:        73087c2c0fd51b1ff543580dadbf3d02dd49a35d
Parent:        dd5f8b3f8c18ff57525ec5c5b35c6e1d218b1000
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 14 23:06:17 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 15 15:24:56 2021 +0200

clang: free on arg parsing

If the parameter would be given twice, the 1st. alloc memleaks.
---
 daemons/lvmlockd/lvmlockd-core.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index a3964c857..e53eebfe7 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -6280,6 +6280,7 @@ int main(int argc, char *argv[])
 		.daemon_fini = NULL,
 		.daemon_main = main_loop,
 	};
+	daemon_host_id_file = NULL;
 
 	static struct option long_options[] = {
 		{"help",            no_argument,       0, 'h' },
@@ -6332,9 +6333,11 @@ int main(int argc, char *argv[])
 			daemon_debug = 1;
 			break;
 		case 'p':
+			free((void*)ds.pidfile);
 			ds.pidfile = strdup(optarg);
 			break;
 		case 's':
+			free((void*)ds.socket_path);
 			ds.socket_path = strdup(optarg);
 			break;
 		case 'g':
@@ -6354,6 +6357,7 @@ int main(int argc, char *argv[])
 			daemon_host_id = atoi(optarg);
 			break;
 		case 'F':
+			free((void*)daemon_host_id_file);
 			daemon_host_id_file = strdup(optarg);
 			break;
 		case 'o':


