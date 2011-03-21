From: Milan Broz <mbroz@redhat.com>
Date: Mon, 21 Mar 2011 16:48:59 +0100
Subject: [PATCH 3/3] Use global libudev context in _set_udev_checking fn
In-Reply-To: <4D8764B0.6060706@redhat.com>
References: <4D8764B0.6060706@redhat.com>
Message-ID: <4D87736B.20008@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/21/2011 03:46 PM, Peter Rajnoha wrote:
> This is just a little cleanup - we use global libudev reference now,
> so there's no need to call udev_new even in existing code. Udev library
> reference is initialized at LVM2 start and finalized at its end
> (see previous patch).

ack

Milan


