From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 31 Aug 2011 16:44:26 +0200
Subject: [PATCH] non-const dm_config_find_node
In-Reply-To: <87k49t4psd.fsf@aldalome.int.mornfall.net.>
References: <87k49t4psd.fsf@aldalome.int.mornfall.net.>
Message-ID: <4E5E48CA.3040001@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 31.8.2011 16:30, Petr Rockai napsal(a):
> Hi,
> 
> this patch replaces const usage of dm_config_find_node with more
> appropriate value-lookup functionality. A number of bugs (copied and
> pasted all over the code) should disappear:
> 
> - most string lookup based on dm_config_find_node would segfault when
>   encountering a non-zero integer (the intention there was to print an
>   error message instead)
> - check for required sections in metadata would have been satisfied by
>   values as well (i.e. not sections)
> - encountering a section in place of expected flag value would have
>   segfaulted (due to assumed but unchecked cn->v != NULL)
> 
> Yours,
>    Petr
> 
> 
> 
> dm_config_find_node.diff
> 
> 


> Index: lib/mirror/mirrored.c

>  
> -	if ((cn = dm_config_find_node(sn, "mirror_log"))) {
> -		if (!cn->v || !cn->v->v.str) {
> -			log_error("Mirror log type must be a string.");
> -			return 0;
> -		}
> -		logname = cn->v->v.str;
> +	if (dm_config_get_str(sn, "mirror_log", &logname)) {
>  		if (!(seg->log_lv = find_lv(seg->lv->vg, logname))) {
>  			log_error("Unrecognised mirror log in "
>  				  "segment %s of logical volume %s.",


When we are doing this change maybe there is some way to combine
dm_config_get_str() and find_lv() to one internal lvm function call - though
error reporting might be tricky so not sure whether it's worth to make some
change here, but this call sequence is used several times.


> @@ -130,14 +125,14 @@ static int _mirrored_text_import(struct 

> +int dm_config_get_list(const struct dm_config_node *cn, const char *path,
> +		       const struct dm_config_value **result)
> +{
> +	const struct dm_config_node *n;
> +
> +	n = _find_config_node(cn, path);
> +	/* TODO when we represent single-item lists consistently, add a check
> +	 * for n->v->next != NULL */
> +	if (!n || !n->v)
> +		return 0;
> +
> +	*result = n->v;
> +	return 1;
> +}
> +
> +int dm_config_get_section(const struct dm_config_node *cn, const char *path,
> +			  const struct dm_config_node **result)
> +{
> +	const struct dm_config_node *n;
> +
> +	n = _find_config_node(cn, path);
> +	if (!n || n->v)
> +		return 0;
> +
> +	*result = n;
> +	return 1;
> +}

Cosmetic - preferring empty break before return;



ACK, Like this one

Zdenek


