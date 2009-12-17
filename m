From: Milan Broz <mbroz@redhat.com>
Date: Thu, 17 Dec 2009 15:12:03 +0100
Subject: [PATCH] Fix removal of multiple devices from a mirror.
In-Reply-To: <871vitg13y.fsf@twilight.int.mornfall.net.>
References: <871vitg13y.fsf@twilight.int.mornfall.net.>
Message-ID: <4B2A3C33.9010603@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/17/2009 02:51 PM, Petr Rockai wrote:
> the code for removing mirror images, as it is, shifts the first failed
> leg twice and fails to shift the second failed one at all, which
> reorders the mirror image array in such a way that a wrong leg is
> removed as a result.

well the code is not easily readable for me.
but the fix seems correct.

> @@ -533,6 +533,7 @@ static int _remove_mirror_images(struct 
>  			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
>  				if (!shift_mirror_images(mirrored_seg, s))
>  					return_0;
> +				s--; /* adjust counter after shifting */

uint32_t s;

if the s drops to max_uint here, it will skip to 0 in next loop.
well, another loop style is probably better...
but let's not complicate it now...

>  				new_area_count--;
>  			}
>  		}

ack.

Milan


