From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:48 +0000 (UTC)
Subject: master - dmeventd: enable new logging
Message-ID: <20151013140348.416EB61207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42a9c8b4a659a44bef1b3150eb6359d562938ca3
Commit:        42a9c8b4a659a44bef1b3150eb6359d562938ca3
Parent:        e50583d7219e01228d697f91a16e91ed1f5efe86
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 15:13:28 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:13:28 2015 +0200

dmeventd: enable new logging

---
 daemons/dmeventd/dmeventd.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 26609db..6f25379 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -674,7 +674,7 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 	 * TODO: audit libdm thread usage
 	 */
 	if (!_in_event_counter++)
-		dm_log_init(_no_intr_log);
+		dm_log_init(_dmeventd_log);
 	_unlock_mutex();
 
 	DEBUGLOG("Starting waitevent task for %s", thread->device.uuid);
@@ -2118,7 +2118,6 @@ int main(int argc, char *argv[])
 
 	openlog("dmeventd", LOG_PID, LOG_DAEMON);
 
-	dm_event_log_set(_debug_level, _use_syslog);
 	dm_log_init(_dmeventd_log);
 
 	(void) dm_prepare_selinux_context(DMEVENTD_PIDFILE, S_IFREG);


