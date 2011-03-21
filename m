From: Milan Broz <mbroz@redhat.com>
Date: Mon, 21 Mar 2011 15:13:13 +0100
Subject: [PATCH] dmeventd protocol versioning mechanism
In-Reply-To: <877hbunlu9.fsf@twilight.int.mornfall.net.>
References: <877hbunlu9.fsf@twilight.int.mornfall.net.>
Message-ID: <4D875CF9.5020100@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/20/2011 11:10 AM, Petr Rockai wrote:
+/*
+ * You can (and have to) call this in place of
+ * daemon_talk(fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0)
+ * -- this call will parse the version reply from dmeventd, in addition to
+ * above call. It is not safe to call this at any other place in the
+ * protocol.
+ */
+int dm_event_get_version(struct dm_event_fifos *fifos, int *version) {
+ char *p;
+ struct dm_event_daemon_message msg = { 0, 0, NULL };
+
+ if (daemon_talk(fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0))
+ return 0;
+ p = msg.data;
+ *version = 0;
+
+ p = strchr(p, ' ') + 1; /* Message ID */
+ p = strchr(p, ' ') + 1; /* HELLO */
+ p = strchr(p, ' '); /* HELLO, once more */


Is this safe? I think it will segfault on malformed reply (no spaces).
strchr(NULL, ...)


Milan


