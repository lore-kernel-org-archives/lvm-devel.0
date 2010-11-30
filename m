From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 30 Nov 2010 04:43:37 +0000
Subject: [PATCH] Scan also special metadata areas (like metadata/dirs) in fmt_from_vgname
In-Reply-To: <4CEFD75D.6060509@redhat.com>
References: <4CEFD75D.6060509@redhat.com>
Message-ID: <20101130044337.GA18385@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

All that said, a hack like this might be the easiest way to fix this in the
short term until the cache handles mdas properly.

On Fri, Nov 26, 2010 at 04:50:53PM +0100, Peter Rajnoha wrote:
> @@ -400,6 +403,11 @@ const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid)
>  		dm_free(devl);
>  	}
>  
> +	dm_list_iterate_items(fmt, &cmd->formats) {
> +		if (fmt->ops->scan && !fmt->ops->scan(fmt))

We can reduce the impact a bit by adding vgname as a parameter to
scan() and only running it if the vginfo got 'lost' within the
function.  (I.e. the first lookup found it, but after the label_reads()
it disappeared.)  

This type of metadata is incompatible with clustering, and memlock isn't
supported either so calling scan() here is inconsequential.


The fmt_from_vgname() triplets can also be optimised a bit:
  The last one should never need to do any label_reads because it follows
  a full scan, so it can return the answer directly from cache.
  The memlock() test before it can be skipped when there is in-filesystem
  metadata (so that the 3rd fmt_from_vgname always gets called).

So that provides an alternative fix I think: add parameter to fmt_from_vgname
telling it to skip the device checks and use that whenever it follows a
lvmcache_label_scan(cmd, 2); record whether or not in-filesystem metadata
is in use and if so avoid returning when memlock is also set.
(Treat raw the same as in-filesystem.)
(Can probably optimise that further too so it only needs to fall through the
triplet of functions the first time.)

Alasdair


