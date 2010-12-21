From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Dec 2010 18:21:47 +0100
Subject: [PATCH 10/23] Fix memory leak of dev_filter on error path
In-Reply-To: <f5f89efaed261f30fa5ce4b21aee5d567ca1f3c0.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<f5f89efaed261f30fa5ce4b21aee5d567ca1f3c0.1292945707.git.zkabelac@redhat.com>
Message-ID: <4D10E22B.3020009@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/21/2010 04:41 PM, Zdenek Kabelac wrote:

> @@ -352,5 +357,8 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
>  		dm_hash_destroy(pf->devices);
>  	dm_free(pf);
>  	dm_free(f);
> +
> +     fail:
> +	real->destroy(real);
>  	return NULL;
>  }

Why not move it to the caller instead - the same like previous two?

	if (!(f4 = persistent_filter_create(f3, dev_cache))) {
		log_error("Failed to create persistent device filter");
+		f3->destroy(f3); 
		return 0;
	}

Milan


