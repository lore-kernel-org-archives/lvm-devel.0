From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 29 May 2012 10:11:53 +0200
Subject: LVM2 ./WHATS_NEW_DM lib/commands/toolcontext.c ...
In-Reply-To: <20120529080919.4906.qmail@sourceware.org>
References: <20120529080919.4906.qmail@sourceware.org>
Message-ID: <4FC484C9.2030708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/29/2012 10:09 AM, prajnoha at sourceware.org wrote:
> Log message:
> 	Remove unsupported udev_get_dev_path libudev call used for checking udev dir.
> 	
> 	With latest changes in the udev, some deprecated functions were removed
> 	from libudev amongst which there was the "udev_get_dev_path" function
> 	we used to compare a device directory used in udev and directore set in
> 	libdevmapper. The "/dev" is hardcoded in udev now (udev version >= 183).

Just for a reference:
  http://cgit.freedesktop.org/systemd/systemd/commit/src/libudev/libudev.h?id=20bbd54f603994a3cc211d2795de16550882ed8d

Peter


