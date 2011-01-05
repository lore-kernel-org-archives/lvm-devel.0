From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 01:11:49 +0000
Subject: [PATCH 05/23] Remove dead assignment in vgconvert_single
In-Reply-To: <2bf1127a19c1b88a3a5d37701967d486b7b54371.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<2bf1127a19c1b88a3a5d37701967d486b7b54371.1292945707.git.zkabelac@redhat.com>
Message-ID: <20110105011149.GM10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 21, 2010 at 04:41:37PM +0100, Zdenek Kabelac wrote:
> 'pe_end' is not used - remove it.
 
>  		pe_start = pv_pe_start(existing_pv);
> -		pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv)
> -		    + pe_start - 1;

Please retain that formula in a comment instead.

Alasdair


