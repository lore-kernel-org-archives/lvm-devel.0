From: Petr Rockai <prockai@redhat.com>
Date: Thu, 15 Mar 2012 09:32:42 +0100
Subject: [PATCH] Remove fifos on dmeventd shutdown
In-Reply-To: <4F60A9CB.5050000@redhat.com> (Peter Rajnoha's message of "Wed,
	14 Mar 2012 15:23:07 +0100")
References: <4F60A9CB.5050000@redhat.com>
Message-ID: <87399atgb9.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Peter Rajnoha <prajnoha@redhat.com> writes:

> I think we should clean these fifos properly (if not using systemd
> activation where they are maintained by systemd itself).
>
> Also, there's missing SIGTERM signal handler registration for the case
> we run in foreground - it leaves the dmeventd.pid in filesystem then.
> (..it would leave the fifos behind as well)

Looks OK to me. Ack.

Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


