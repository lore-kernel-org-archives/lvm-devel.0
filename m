From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 00:35:05 +0000
Subject: [PATCH 10/23] Fix memory leak of dev_filter on error path
In-Reply-To: <4D11CD5A.5090104@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<f5f89efaed261f30fa5ce4b21aee5d567ca1f3c0.1292945707.git.zkabelac@redhat.com>
	<4D10E22B.3020009@redhat.com> <4D11CD5A.5090104@redhat.com>
Message-ID: <20110105003505.GH10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 22, 2010 at 11:05:14AM +0100, Zdenek Kabelac wrote:
> I'm not sure about the best logic - so used this as a plain proposal - of
> course both variants could be seen as valid. And as I've been already fixing
> error messages in the function it self, I've put the call of destructor there.
> 
> My idea was - one the persistent_filter_create() is called - it takes
> ownership of the passed struct dev_filter.
 
I don't think it matters which you pick, but add comments to make it clear
who's responsible for cleanup.

Alasdair


