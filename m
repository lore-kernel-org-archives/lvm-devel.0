From: Milan Broz <mbroz@redhat.com>
Date: Mon, 21 Mar 2011 16:40:55 +0100
Subject: [PATCH 2/3] Query udev database to obtain device list for device cache
In-Reply-To: <4D876449.5040500@redhat.com>
References: <4D876449.5040500@redhat.com>
Message-ID: <4D877187.7090206@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/21/2011 03:44 PM, Peter Rajnoha wrote:
> Use libudev to obtain the list of all block device nodes and associated symlinks
> and construct the device cache from this information. This avoids accessing
> inappropriate devices or subdirectories found in /dev that is managed by udev.

ack. it need some testing but definitely it should go in.

Milan


