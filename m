From: Ondrej Kozina <okozina@redhat.com>
Date: Mon, 09 Mar 2015 09:31:43 +0100
Subject: [PATCH] fsadm: add support for btrfs
In-Reply-To: <1425883705-8022-1-git-send-email-lzhong@suse.com>
References: <1425883705-8022-1-git-send-email-lzhong@suse.com>
Message-ID: <54FD5A6F.90806@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/09/2015 07:48 AM, Lidong Zhong wrote:
> Run `btrfs check` to check filesystem
> Run `btrfs filesystem show` to get the filesystem size and
> `btrfs filesystem resize` to resize.
>

Hi,

thank you for the patch but I'm afraid it is not correct. For example it 
doesn't seem to deal with the possibility of btrfs volume spanning 
across multiple block devices. You have to resize (meant with btrfs 
tools) specific subvolume to not to break the filesystem on LV about to 
get resized with lvresize.

I proposed similar patch before 
(http://www.redhat.com/archives/lvm-devel/2012-November/msg00052.html) 
but in the end came to conclusion it was not worth the pain considering 
the btrfs-check couldn't detect even elemental fs breakage. Is the state 
of btrfs-check tool better than what I described earlier in my patch header?

Kind regards
Ondrej

PS: The original patch is from 2012 so perhaps some of the magic I used 
to extract proper btrfs device id is useless as of now. At least I hope 
so...


