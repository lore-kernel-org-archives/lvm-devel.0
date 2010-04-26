From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Apr 2010 15:49:40 +0100
Subject: [PATCH 22/22] Replicator: man pages for lvcreate, lvchange
In-Reply-To: <3db2ca3c8ab62d2e788d6faa08b6c3f7029eddfc.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<3db2ca3c8ab62d2e788d6faa08b6c3f7029eddfc.1271085009.git.zkabelac@redhat.com>
Message-ID: <20100426144939.GT23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 12, 2010 at 05:21:50PM +0200, Zdenek Kabelac wrote:
> +[\-\-activesite Site]
> +[\-\-passivesite Site]

> +.I \-\-activesite
> +Marks site as active. Note: Only one site from replicator could be
> +marked active with actual implementation and this site must be
> +local site.
> +.TP
> +.I \-\-passivesite
> +Marks site as passive which is default.

Inconsistency.  Does it or does it not take 'Site' as an argument?
Can both be set together as the synopsis implies, or not?

What combinations of those args are meant to be permitted, or not?
--activesite site1 --passivesite site1  ?

(If it's either/or, use '|' or split into 2 args.)

Alasdair


