From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 21:06:28 +0100
Subject: [PATCH - v2] LVM: New flag, LV_REBUILD
In-Reply-To: <1321293985.6418.0.camel@f14.redhat.com>
References: <1320963969.7209.1.camel@f14.redhat.com>
	<1321293985.6418.0.camel@f14.redhat.com>
Message-ID: <4EC417C4.8060707@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.11.2011 19:06, Jonathan Brassow napsal(a):
> Changes from previous:
> - New rebuild flag is now written to on-disk LVM metadata
> - An additional metadata write/commit is necessary to clear the flag
> after a proper resume
> - flags.c file updated
>
>   brassow
>
> Add new flag, LV_REBUILD.
>
> Until now, I had been using the LV_NOTSYNCED as a flag to indicate that RAID
> sub-LVs needed to be rebuilt.  (The 'rebuild' parameter is then specified in
> the DM CTR table.)  However, I don't want to use a flag that gets written to
> the LVM metadata... and the LV_NOTSYNCED flag's original meaning does not
> suite the purpose adequately.
>
> This patch proposes and uses a new flag, LV_REBUILD.

Hmm so now - when it's written to disk - it looks like  LV_REBUILD and 
LV_NOTSYNCED is mostly the same meaning - except  one is used in raid
and original in mirror ?

So I think it's easier to keep just one flag ?
(Well the bit field space is somewhat limited)

Zdenek


