From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 30 Apr 2010 12:26:27 +0100
Subject: [PATCH 3/3] Fix internal error for errornous regex insert
In-Reply-To: <0d6e9e51fc54fe270335af224c85ffb8d7dd53c6.1272618315.git.zkabelac@redhat.com>
References: <cover.1272618315.git.zkabelac@redhat.com>
	<0d6e9e51fc54fe270335af224c85ffb8d7dd53c6.1272618315.git.zkabelac@redhat.com>
Message-ID: <20100430112627.GE14077@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Apr 30, 2010 at 11:07:21AM +0200, Zdenek Kabelac wrote:
> Fix error message shown for incorrect regex in config file:
> 'Internal error: _vginfos list should be empty'
> When regex parser fails lvmcache_init() is not invoked - thus
> _vginfos list is not initiliased.
 
If lvmcache_init is not called, neither should lvmcache_destroy be!

Alasdair


