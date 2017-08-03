From: Marcus Müller <marcus@hostalia.de>
Date: Thu, 3 Aug 2017 10:44:17 +0200
Subject: [PATCH 0/1] adding Btrfs resizing capability to lvresize/fsadm.sh
In-Reply-To: <20170802174235.19869-1-marcus@hostalia.de>
References: <20170802174235.19869-1-marcus@hostalia.de>
Message-ID: <3d78f6d7-dd89-71cb-e754-88a290287404@hostalia.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

So,

I'll admit that me spontaneously handing in above feature patch
yesterday was an act of "let's get this out of my head before I go
home". For private purposes, I wanted lvresize -r to deal with BTRFS, too.
Am I right here to post feature branches at all? Any copyright
assignments I need to take care of?

Regarding the patch:

BTRFS is a bit special in that one filesystem can spread across multiple
physical volumes. In the case of multi-volume BTRFS, we need to specify
which specific one needs resizing; hence the whole devid dance.
Also: BTRFS needs to be mounted to be resized; mount detection sometimes
fails. That is not an issue, since it's safe to multi-mount a filesystem
and resize it. So in fact, I was considering skipping the checking for
mountedness completely, but then decided against it to keep the resize_*
functions as uniform and recognizable as possible.

Best regards,
Marcus M?ller

On 08/02/2017 07:42 PM, Marcus M?ller wrote:
> Btrfs support was missing from LVM's volume resize tools.
> Fixed that.
> 
> Marcus M?ller (1):
>   added resizing for btrfs
> 
>  scripts/fsadm.sh | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 68 insertions(+), 1 deletion(-)
> 


