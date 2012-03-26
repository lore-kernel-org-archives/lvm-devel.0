From: Petr Rockai <prockai@redhat.com>
Date: Mon, 26 Mar 2012 14:06:46 +0200
Subject: [PATCH][just nitpicking :)] Make vgscan behaviour consistent with pvscan
In-Reply-To: <4F6B1F13.5080103@redhat.com> (Peter Rajnoha's message of "Thu,
	22 Mar 2012 13:46:11 +0100")
References: <4F6B1F13.5080103@redhat.com>
Message-ID: <87398vsh0p.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Peter Rajnoha <prajnoha@redhat.com> writes:
> Just this minor thing... Are you OK with this?
>
> If using "--cache" opt, we directly scan and update lvmetad if running.
> If not using "--cache" opt, we get the info from lvmetad if running.

yes, I think this is good for UI consistency. One thing to watch out for
though is on-disk metadata inconsistencies. Before the patch, any
"vgscan" would notice those, but afterwards, only "vgscan --cache" can
be used to detect bad on-disk metadata.

We could also want to extend pvscan --cache to report (and maybe fix?)
any metadata inconsistencies it may find.

[snip; patch looks OK]

Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


