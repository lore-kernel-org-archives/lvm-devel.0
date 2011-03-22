From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 08:42:42 +0100
Subject: [PATCH] fix bugs in temporary mirror layer handling
In-Reply-To: <24010.4646225975$1300623398@news.gmane.org>
References: <24010.4646225975$1300623398@news.gmane.org>
Message-ID: <4D8852F2.7020401@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.3.2011 00:33, Petr Rockai napsal(a):

Just Some minor cosmetics

> while working on vgreduce --removemissing --force, I have uncovered
> about half a dozen bugs in handling mirror image removal with temporary
> layers present in the mirror stack.
> 
> The patch did not break any tests from the test suite for me. It is a
> prerequisite for vgreduce --removemissing --force, but it also fixes the
> above bugs when triggered in plain lvconvert and in lvconvert --repair.
> 
> 
> 
> temp-mirror-layer-fixes.diff
> 
> 
 array */
>  	for (s = mirrored_seg->area_count - 1;
> -	     s >= 0 && old_area_count - new_area_count < num_removed;
> +	     s >= 0 && old_area_count - new_area_count < orig_removed;
>  	     s--) {

braces ?

> @@ -825,9 +828,13 @@ static int _remove_mirror_images(struct 
>  			if (!shift_mirror_images(mirrored_seg, s))
>  				return_0;
>  			new_area_count--;
> +			num_removed ++;

++num_removed

> +			++ retries;

++retries

Zdenek


