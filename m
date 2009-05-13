From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 13 May 2009 15:43:29 -0400
Subject: [PATCH] Add escape sequence for ':' in command's PV list
In-Reply-To: <4A0AAA51.8040609@redhat.com>
References: <4A0AAA51.8040609@redhat.com>
Message-ID: <1242243809.2556.19.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2009-05-13 at 13:09 +0200, Peter Rajnoha wrote:
> Hi,
> 
> this little patch provides an escape sequence in command's PV list
> where ':' is also used as a delimiter for extent ranges. To escape
> this char, we just double it, so '::' is translated to ':' and ':'
> is extent range delimiter.
> (BZ #491409)
> 
> Peter
> 
> 
> diff --git a/tools/toollib.c b/tools/toollib.c
> index aa33468..b5a43b5 100644
> --- a/tools/toollib.c
> +++ b/tools/toollib.c
> @@ -1095,8 +1095,9 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
>  	struct dm_list *r;
>  	struct pv_list *pvl;
>  	struct dm_list tags, arg_pvnames;
> -	const char *pvname = NULL;
> +	char *pvname = NULL;
>  	char *colon, *tagname;
> +	char *ptr, *ptr_end;
>  	int i;
>  
>  	/* Build up list of PVs */
> @@ -1128,9 +1129,21 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
>  			continue;
>  		}
>  
> -		pvname = argv[i];
> +		ptr = pvname = argv[i];
> +		ptr_end = strchr(ptr, '\0');
> +		colon = NULL;
>  
> -		if ((colon = strchr(pvname, ':'))) {
> +		while ((ptr = strchr(ptr, ':'))) {
> +			if (ptr[1] == ':') {
> +				memmove(ptr, ptr + 1, ptr_end - ptr);
> +				ptr_end--;
> +			}
> +			else if (!colon)
> +				colon = ptr;
> +			ptr++;
> +		}
> +
> +		if (colon) {
>  			if (!(pvname = dm_pool_strndup(mem, pvname,
>  						    (unsigned) (colon -
>  								pvname)))) {

Reviewed and the code works as advertised, however...

This code should probably go inside lvm-string.c with the other code
that handles special characters.
Also, think about consistency among pvcreate, vgcreate, and lvcreate.

Attached is a patch for a small test I put together that I think should
work once this bug is fixed.  It does not work currently because
arguments to pvcreate and vgcreate are handled differently than lvcreate
(it will pass if you change these args to just $dev1 instead of
$dev1_escaped).  I know, it does not make sense to specify a pe range
for pvcreate or vgcreate.  But shouldn't we be consistent, or at least
very much clarify the arguments are different?  I can just imagine
someone scripting something and then being surprised when they needed to
quote only for lvcreate, pvmove, etc.

To see where it fails look at the verbose output of pvcreate or you can
just read the pvcreate code.


-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0001-Add-pvcreate-test-for-escaped.patch
Type: text/x-patch
Size: 1800 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090513/efcbda86/attachment.bin>
