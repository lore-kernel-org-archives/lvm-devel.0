From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 22 Dec 2010 11:05:14 +0100
Subject: [PATCH 10/23] Fix memory leak of dev_filter on error path
In-Reply-To: <4D10E22B.3020009@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>	<f5f89efaed261f30fa5ce4b21aee5d567ca1f3c0.1292945707.git.zkabelac@redhat.com>
	<4D10E22B.3020009@redhat.com>
Message-ID: <4D11CD5A.5090104@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 21.12.2010 18:21, Milan Broz napsal(a):
> On 12/21/2010 04:41 PM, Zdenek Kabelac wrote:
> 
>> @@ -352,5 +357,8 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
>>  		dm_hash_destroy(pf->devices);
>>  	dm_free(pf);
>>  	dm_free(f);
>> +
>> +     fail:
>> +	real->destroy(real);
>>  	return NULL;
>>  }
> 
> Why not move it to the caller instead - the same like previous two?
> 
> 	if (!(f4 = persistent_filter_create(f3, dev_cache))) {
> 		log_error("Failed to create persistent device filter");
> +		f3->destroy(f3); 
> 		return 0;
> 	}
> 


I'm not sure about the best logic - so used this as a plain proposal - of
course both variants could be seen as valid. And as I've been already fixing
error messages in the function it self, I've put the call of destructor there.

My idea was - one the persistent_filter_create() is called - it takes
ownership of the passed struct dev_filter.

Your proposal means - that in error case the function doesn't take
responsibility for this value and caller is supposed to cleanup.

Do we agree on this semantic ?

Zdenek




