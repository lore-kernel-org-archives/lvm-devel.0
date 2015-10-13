From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:07 +0000 (UTC)
Subject: master - cleanup: remove multilog
Message-ID: <20151013140407.5F4D7602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e2261dbd1d489dff158fce88a705a680aaaa3da
Commit:        0e2261dbd1d489dff158fce88a705a680aaaa3da
Parent:        842a7a17e3c0ffc0467ef23a3b59e4e8af2c8d74
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 09:40:39 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:22:57 2015 +0200

cleanup: remove multilog

---
 daemons/dmeventd/dmeventd.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 7ad30b3..3e54f79 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -2152,11 +2152,6 @@ int main(int argc, char *argv[])
 
 	_init_thread_signals();
 
-	//multilog_clear_logging();
-	//multilog_add_type(std_syslog, &logdata);
-	//multilog_init_verbose(std_syslog, _LOG_DEBUG);
-	//multilog_async(1);
-
 	pthread_mutex_init(&_global_mutex, NULL);
 
 	if (!_systemd_activation && !_open_fifos(&fifos))
@@ -2191,7 +2186,6 @@ int main(int argc, char *argv[])
 		_cleanup_unused_threads();
 	}
 
-
 	pthread_mutex_destroy(&_global_mutex);
 
 	log_notice("dmeventd shutting down.");


