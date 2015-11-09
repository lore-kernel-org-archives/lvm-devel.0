From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:29:08 +0000 (UTC)
Subject: master - cleanup: use fputs for plain strings
Message-ID: <20151109092908.6DBE260971@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=11151121aa25c331cdb821281b0c4719bed040ea
Commit:        11151121aa25c331cdb821281b0c4719bed040ea
Parent:        c4c5635870c7273e61a0832431d264b8cf11a62f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 7 21:15:05 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:52 2015 +0100

cleanup: use fputs for plain strings

Use fputs() when printing plain string,
easier then fprintf which needs to parse it.

Also check fd before close is >= 0 -
it is - but coverity fail to see it, so eliminate
this false-positive warning.
---
 daemons/dmeventd/dmeventd.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 6c04c1b..b7fff9a 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1956,21 +1956,21 @@ static int _reinstate_registrations(struct dm_event_fifos *fifos)
 		    !(dev_name = strtok(NULL, _delim)) ||
 		    !(mask = strtok(NULL, _delim)) ||
 		    !(timeout = strtok(NULL, _delim))) {
-			fprintf(stderr, _failed_parsing_msg);
+			fputs(_failed_parsing_msg, stderr);
 			continue;
 		}
 
 		errno = 0;
 		mask_value = strtoul(mask, &endp, 10);
 		if (errno || !endp || *endp) {
-			fprintf(stderr, _failed_parsing_msg);
+			fputs(_failed_parsing_msg, stderr);
 			continue;
 		}
 
 		errno = 0;
 		timeout_value = strtoul(timeout, &endp, 10);
 		if (errno || !endp || *endp) {
-			fprintf(stderr, _failed_parsing_msg);
+			fputs(_failed_parsing_msg, stderr);
 			continue;
 		}
 
@@ -2255,9 +2255,9 @@ int main(int argc, char *argv[])
 
 	log_notice("dmeventd shutting down.");
 
-	if (close(fifos.client))
+	if (fifos.client >= 0 && close(fifos.client))
 		log_sys_error("client close", fifos.client_path);
-	if (close(fifos.server))
+	if (fifos.server >= 0 && close(fifos.server))
 		log_sys_error("server close", fifos.server_path);
 
 	if (_use_syslog)


