From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 7 Oct 2009 16:05:03 +0100
Subject: [PATCH 01/13] Replicator: export out_ function for modules
In-Reply-To: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
Message-ID: <20091007150503.GC3054@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Oct 05, 2009 at 04:00:28PM +0200, Zdenek Kabelac wrote:
> +/* insert new line */
> +int out_newline(struct formatter *f)
> +{
> +	outnl(f);
> +	return 0;

Should return 1 here, and the caller has to check that.
Instead, I think the outnl macro should be changed to work like the outf one.
(make the 'f->nl' part internal to an export.c function instead of the header file)
The idea was that the callers would be using this so frequently, it was
clearer just writing 'outf(...)'  than 'if (!out_text(...)) return_0;' everywhere.

Alasdair


