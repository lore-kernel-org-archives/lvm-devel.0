From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 00:12:57 +0000
Subject: [PATCH 17/23] Add check for dm_snprintf result
In-Reply-To: <4D11D447.2020808@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<a8e673868df6582ac8916843f7f5c77d8dcdb2cf.1292945707.git.zkabelac@redhat.com>
	<4D10E62F.6070201@redhat.com> <4D11D447.2020808@redhat.com>
Message-ID: <20110105001257.GD10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 22, 2010 at 11:34:47AM +0100, Zdenek Kabelac wrote:
> >> +		if (dm_snprintf(lockname, sizeof(lockname), "%c_%s",
> >> +				(is_orphan_vg(resource) ||
> >> +				 is_global_vg(resource) ||
> >> +				 (flags & LCK_CACHE)) ?  'P' : 'V',
> >> +				resource)  < 0) {
> >> +			log_error("Locking resource %s too long.", resource);
> >> +			return 0;
> >> +		}
> > I cannot imagine how this can happen. First parm is fixed char, second is resource string
> > with exact length. And char lockname[PATH_MAX];
> One shiny afternoon day someone could think about using 256byte long VG and LV
> uuids and it will nicely fail ;)
 
I've no objection to adding tests like that, though adding '(void)' in places like
this that are safe is also fine.

Alasdair


