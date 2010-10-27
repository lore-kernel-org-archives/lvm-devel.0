From: ejt@redhat.com <ejt@redhat.com>
Date: Wed, 27 Oct 2010 11:19:04 +0100
Subject: [PATCH 4/5] Fix theoretical usage of NULL pointer dereference
In-Reply-To: <20101026133743.GI29400@agk-dp.fab.redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
	<a1cfd7e4e519a821b545e3a299eb01866ed76877.1288097372.git.zkabelac@redhat.com>
	<20101026133743.GI29400@agk-dp.fab.redhat.com>
Message-ID: <874oc8sztz.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Tue, 26 Oct 2010 14:37:43 +0100,
Alasdair G Kergon wrote:
> 
> On Tue, Oct 26, 2010 at 02:59:25PM +0200, Zdenek Kabelac wrote:
> > @@ -97,6 +97,12 @@ int ttree_insert(struct ttree *tt, unsigned int *key, void *data)
> 
> > +	if (!*c) {
> > +		log_error(INTERNAL_ERROR "Insert failed.");
> 
> What am I missing here?
> Isn't that condition you are proposing to add logically impossible to
> trigger?!

Yes, it can't happen, as I said the first time this patch went round.

One thing I'm not clear on is how much benefit we're seeing from the
CLang build?  Kabi, how many genuine bugs did you find when you went
through this process?  If the benefits are real, then we can live with
check like these.  It would be nice if it was clearer that they are
only there to pacify clang, maybe put a conditional compile in so
they're only included with the clang build?

- Joe


