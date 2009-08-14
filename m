From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 14 Aug 2009 16:40:51 +0200
Subject: [PATCH] use /sbin/blkid from util-linux-ng for newer udev
In-Reply-To: <4A85319A.8030608@impulze.org>
References: <4A85319A.8030608@impulze.org>
Message-ID: <4A857773.5050003@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/14/2009 11:42 AM, Daniel Mierswa wrote:
> udev no longer provides vol_id and uses /sbin/blkid from util-linux-ng
> (util-linux won't work)

> -IMPORT{program}="vol_id --export $tempnode"
> +IMPORT{program}="/sbin/blkid -o udev -p $tempnode"

Yes, you're right. I've changed it.
Thanks for the reminder.

Peter


