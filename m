From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 20 Mar 2011 21:41:49 +0000
Subject: LVM2/libdm/ioctl libdm-iface.c
In-Reply-To: <4D85FC79.6050709@redhat.com>
References: <20110320020053.24940.qmail@sourceware.org>
	<4D85FC79.6050709@redhat.com>
Message-ID: <20110320214149.GZ11163@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Mar 20, 2011 at 02:09:13PM +0100, Zdenek Kabelac wrote:
> My patch was only fixing error reporting logic.
 
One output case:
  Failed to get device-mapper version
  Support for older device-mapped version is disabled.

A quite misleading pair of messages, I think.

Another output case, when only one version is compiled into the binary:
  ...
  Support for older device-mapped version is disabled.

Support was not compiled in so we shouldn't mention anything about it to the
user.

> Did I get this rule wrong - are there some exceptions?

  We must always have at least one log_error on the error path, but as
few as possible.
  We try to place it as low down in the code as we can consistent with
minimising the number of log_errors: it is normally, but not always, at the
lowest level.  
  'stack' is used in other places on error paths.
 
Alasdair


