From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 04 Oct 2011 10:09:51 +0200
Subject: [PATCH v3 06/18] fsadm: Fsck extN before resize only if it is not mounted
In-Reply-To: <1317130971-24173-7-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-7-git-send-email-lczerner@redhat.com>
Message-ID: <4E8ABF4F.9090008@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
> Signed-off-by: Lukas Czerner<lczerner@redhat.com>
> ---
>   scripts/fsadm.sh |    3 ++-
>   1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
> index d4901d1..f43d72e 100755
> --- a/scripts/fsadm.sh
> +++ b/scripts/fsadm.sh
> @@ -415,8 +415,9 @@ resize_ext() {
>   	decode_size $1 $BLOCKSIZE
>   	FSFORCE=$FORCE
>
> +	detect_mounted
>   	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
> -		detect_mounted&&  verbose "$RESIZE_EXT needs unmounted filesystem"&&  try_umount
> +		[ "$MOUNTED" ]&&  verbose "$RESIZE_EXT needs unmounted filesystem"&&  try_umount
>   		REMOUNT=$MOUNTED
>   	fi
>


Patches like these need to go in the front of the patch set  so they could be 
eaily applied upstream.


Zdenek


