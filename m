From: Petr Rockai <prockai@redhat.com>
Date: Mon, 21 Mar 2011 16:32:55 +0100
Subject: [PATCH] dmeventd protocol versioning mechanism
In-Reply-To: <4D875CF9.5020100@redhat.com> (Milan Broz's message of "Mon, 21
	Mar 2011 15:13:13 +0100")
References: <877hbunlu9.fsf@twilight.int.mornfall.net.>
	<4D875CF9.5020100@redhat.com>
Message-ID: <87pqpkmqu0.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:

> On 03/20/2011 11:10 AM, Petr Rockai wrote:
> +/*
> + * You can (and have to) call this in place of
> + * daemon_talk(fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0)
> + * -- this call will parse the version reply from dmeventd, in addition to
> + * above call. It is not safe to call this at any other place in the
> + * protocol.
> + */
> +int dm_event_get_version(struct dm_event_fifos *fifos, int *version) {
> + char *p;
> + struct dm_event_daemon_message msg = { 0, 0, NULL };
> +
> + if (daemon_talk(fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0))
> + return 0;
> + p = msg.data;
> + *version = 0;
> +
> + p = strchr(p, ' ') + 1; /* Message ID */
> + p = strchr(p, ' ') + 1; /* HELLO */
> + p = strchr(p, ' '); /* HELLO, once more */
>
>
> Is this safe? I think it will segfault on malformed reply (no spaces).
> strchr(NULL, ...)

it is not (safe), on the other hand there's code in other places in
libdevmapper-event that assumes correctly formatted messages and will
segfault otherwise. Can be made safe fairly easy though (just adding if
(p)'s) so I'll do that before checking it in.

Yours,
   Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


